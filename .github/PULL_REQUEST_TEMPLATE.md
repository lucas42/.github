<!--
⚠️ Production dependencies ⚠️
If this PR needs a MANUAL production change to work — a new credential, config value,
service/sidecar, or linked credential that must be set in prod before/alongside the deploy —
add a section with EXACTLY this heading at the very TOP of the description, listing what must
be set and by whom (lucas42-only creds especially). OMIT the section entirely when there are none.

Why it's at the top and mandatory: merge auto-deploys, so the approver must confirm these are
present in prod BEFORE approving — a change that ships ahead of its creds crash-loops in prod
(see the 2026-07-09 lucos_locations incident). Keep the rest of the description concise so the
⚠️ marker, when present, is impossible to miss.
-->

## What & why

<!-- Concise: what this changes and why. Link the issue, e.g. Closes #N. -->
