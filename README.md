# lucas42/.github

This repository hosts org-wide reusable GitHub Actions workflows for the `lucas42` organisation.

## Naming convention

Workflow files are named with a prefix indicating their type:

- `reusable-*` — reusable workflows intended to be called from other repos via `uses:`
- No prefix — local workflows that run directly in this repo (e.g. `auto-merge.yml`, `smoke-test.yml`)

## Reusable workflows

| Workflow | Purpose |
|---|---|
| `.github/workflows/reusable-dependabot-auto-merge.yml` | Auto-merges Dependabot pull requests using `GITHUB_TOKEN` |
| `.github/workflows/reusable-code-reviewer-auto-merge.yml` | Auto-merges pull requests approved by `lucos-code-reviewer[bot]` and closes linked issues on merge |
| `.github/workflows/reusable-convention-check.yml` | Checks that a repo follows the standard lucos conventions |

## Versioning

This repo uses semantic versioning tags (e.g. `v1.0.0`, `v1.1.0`). A new tag is created automatically after every merge to `main`, once the smoke test suite passes:

- **Minor bump** (`v1.0.0` → `v1.1.0`): every merge to `main`
- **Major bump** (`v1.0.0` → `v2.0.0`): reserved for breaking changes to the caller workflow interface (e.g. new required secrets, changed trigger requirements) — done manually

### Smoke test gate

The `release.yml` workflow only tags a commit if the smoke test suite passes. This ensures callers are never automatically updated to a broken version.

**Known limitation**: the smoke test suite currently only covers `reusable-dependabot-auto-merge`. Changes to `reusable-code-reviewer-auto-merge` or `reusable-convention-check` are tagged without end-to-end smoke coverage.

### Pinning callers

Callers should pin to a tag (not a bare SHA) so Dependabot can detect and open PRs when new versions are published:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/reusable-dependabot-auto-merge.yml@v1.0.0
```

Dependabot will open PRs to update `@v1.0.0` → `@v1.1.0` etc., which auto-merge via the `reusable-dependabot-auto-merge` workflow itself.

## Usage

Call a reusable workflow from any repo in the `lucas42` org:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/reusable-dependabot-auto-merge.yml@v1.0.0
```

For the code-reviewer workflow, secrets must be passed explicitly:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/reusable-code-reviewer-auto-merge.yml@v1.0.0
    secrets:
      CODE_REVIEWER_APP_ID: ${{ secrets.CODE_REVIEWER_APP_ID }}
      CODE_REVIEWER_PRIVATE_KEY: ${{ secrets.CODE_REVIEWER_PRIVATE_KEY }}
```

See each workflow file for full documentation.
