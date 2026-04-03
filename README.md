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

## Usage

Call a reusable workflow from any repo in the `lucas42` org:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/reusable-dependabot-auto-merge.yml@main
```

For the code-reviewer workflow, secrets must be passed explicitly:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/reusable-code-reviewer-auto-merge.yml@main
    secrets:
      CODE_REVIEWER_APP_ID: ${{ secrets.CODE_REVIEWER_APP_ID }}
      CODE_REVIEWER_PRIVATE_KEY: ${{ secrets.CODE_REVIEWER_PRIVATE_KEY }}
```

See each workflow file for full documentation.
