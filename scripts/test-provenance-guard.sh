#!/usr/bin/env bash
# Runs the real `provenance` step script from reusable-dependabot-auto-merge.yml
# against a fake `gh`, one scenario per case. Needs python3 with PyYAML.
set -u
cd "$(dirname "$0")/.."
WORKFLOW=.github/workflows/reusable-dependabot-auto-merge.yml
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

python3 - "$WORKFLOW" "$TMP/step.sh" "$TMP/arm.sh" <<'PY'
import sys, yaml
steps = yaml.safe_load(open(sys.argv[1]))["jobs"]["provenance"]["steps"]
open(sys.argv[2], "w").write(next(s["run"] for s in steps if s.get("id") == "check"))
arm = yaml.safe_load(open(sys.argv[1]))["jobs"]["dependabot"]["steps"]
open(sys.argv[3], "w").write(next(s["run"] for s in arm if s.get("id") == "arm"))
PY

mkdir "$TMP/bin"
cat > "$TMP/bin/gh" <<'GH'
#!/usr/bin/env bash
# Fake gh. Behaviour comes from env: AUTHORS (newline list), EXPECTED, LIST_FAILS, COUNT_FAILS, STILL_ARMED.
case "$*" in
  *"/commits?"*) [ -n "${LIST_FAILS:-}" ] && exit 1; printf '%s' "${AUTHORS:-}"; [ -n "${AUTHORS:-}" ] && echo ;;
  "api repos/"*) [ -n "${COUNT_FAILS:-}" ] && exit 1; echo "${EXPECTED:-0}" ;;
  "pr merge --disable-auto"*) echo disarmed >> "$CALLS" ;;
  "pr merge --auto"*) echo armed >> "$CALLS" ;;
  "pr view"*headRefOid*) [ -n "${VIEW_FAILS:-}" ] && exit 1; echo "${CURRENT_HEAD:-}" ;;
  "pr view"*) [ -n "${STILL_ARMED:-}" ] && echo '{"enabled":true}' ;;
esac
exit 0
GH
chmod +x "$TMP/bin/gh"

fail=0
run_case() { # name expected_armable expect_disarm exit_code [VAR=val ...]
  local name=$1 want=$2 disarm=$3 code=$4; shift 4
  : > "$TMP/out"; : > "$TMP/calls"
  env "$@" PATH="$TMP/bin:$PATH" CALLS="$TMP/calls" GITHUB_OUTPUT="$TMP/out" GITHUB_TOKEN=x \
    REPO=o/r PR_NUMBER=1 PR_URL=https://github.com/o/r/pull/1 bash -e "$TMP/step.sh" > "$TMP/log" 2>&1
  local rc=$? got; got=$(tail -n1 "$TMP/out" | cut -d= -f2)
  local did=no; [ -s "$TMP/calls" ] && did=yes
  if [ "$got" = "$want" ] && [ "$did" = "$disarm" ] && [ "$rc" = "$code" ]; then echo "PASS: $name"
  else echo "FAIL: $name (armable=$got want $want, disarm=$did want $disarm, exit=$rc want $code)"; sed 's/^/    /' "$TMP/log"; fail=1; fi
}

DEP='dependabot[bot]'
run_case "only Dependabot commits arm"            true  no  0 "AUTHORS=$DEP"$'\n'"$DEP" EXPECTED=2
run_case "a foreign commit disarms"               false yes 0 "AUTHORS=$DEP"$'\n'"lucos-developer[bot]" EXPECTED=2
run_case "an unlinked author disarms"             false yes 0 "AUTHORS=$DEP"$'\n'"unlinked-author" EXPECTED=2
run_case "an empty commit list disarms"           false yes 0 AUTHORS= EXPECTED=0
run_case "a commits API error disarms"            false yes 0 LIST_FAILS=1
run_case "a PR count API error disarms"           false yes 0 "AUTHORS=$DEP" COUNT_FAILS=1
run_case "a truncated commit list disarms"        false yes 0 "AUTHORS=$DEP" EXPECTED=300
run_case "failure to disarm fails the job"        false yes 1 "AUTHORS=lucos-developer[bot]" EXPECTED=1 STILL_ARMED=1

run_arm_case() { # name expect_armed exit_code [VAR=val ...]
  local name=$1 want=$2 code=$3; shift 3
  : > "$TMP/calls"
  env "$@" PATH="$TMP/bin:$PATH" CALLS="$TMP/calls" GITHUB_TOKEN=x PR_URL=https://github.com/o/r/pull/1 \
    EVENT_HEAD_SHA=aaa bash -e "$TMP/arm.sh" > "$TMP/log" 2>&1
  local rc=$?; local did=no; grep -qx armed "$TMP/calls" && did=yes
  if [ "$did" = "$want" ] && [ "$rc" = "$code" ]; then echo "PASS: $name"
  else echo "FAIL: $name (armed=$did want $want, exit=$rc want $code)"; sed 's/^/    /' "$TMP/log"; fail=1; fi
}
run_arm_case "arming proceeds when the head is unchanged" yes 0 CURRENT_HEAD=aaa
run_arm_case "arming is skipped when the head moved"       no  0 CURRENT_HEAD=bbb
run_arm_case "arming does not happen if the head can't be read" no 1 VIEW_FAILS=1
exit $fail
