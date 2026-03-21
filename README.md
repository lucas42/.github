# lucas42/.github

This repository hosts org-wide reusable GitHub Actions workflows for the `lucas42` organisation.

## Reusable workflows

| Workflow | Purpose |
|---|---|
| `.github/workflows/dependabot-auto-merge.yml` | Auto-merges Dependabot pull requests using `GITHUB_TOKEN` |
| `.github/workflows/code-reviewer-auto-merge.yml` | Auto-merges pull requests approved by `lucos-code-reviewer[bot]` and closes linked issues on merge |

## Usage

Call a reusable workflow from any repo in the `lucas42` org:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/dependabot-auto-merge.yml@main
```

For the code-reviewer workflow, secrets must be passed explicitly:

```yaml
jobs:
  auto-merge:
    uses: lucas42/.github/.github/workflows/code-reviewer-auto-merge.yml@main
    secrets:
      CODE_REVIEWER_APP_ID: ${{ secrets.CODE_REVIEWER_APP_ID }}
      CODE_REVIEWER_PRIVATE_KEY: ${{ secrets.CODE_REVIEWER_PRIVATE_KEY }}
```

See each workflow file for full documentation.

