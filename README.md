# Release Engineering Repo Standards

Standards and workflows for release engineering repositories

- [Release Engineering Repo Standards](#release-engineering-repo-standards)
  - [Workflows](#workflows)
    - [Dependabot auto-merge](#dependabot-auto-merge)
      - [Dependabot auto-merge Example](#dependabot-auto-merge-example)
      - [Dependabot auto-merge Secrets](#dependabot-auto-merge-secrets)
      - [Dependabot auto-merge Inputs](#dependabot-auto-merge-inputs)
      - [Dependabot auto-merge Outputs](#dependabot-auto-merge-outputs)
    - [Ensure label](#ensure-label)
      - [Ensure label Example](#ensure-label-example)
      - [Ensure label Secrets](#ensure-label-secrets)
      - [Ensure label Inputs](#ensure-label-inputs)
      - [Ensure label Outputs](#ensure-label-outputs)
  - [Contributing](#contributing)

## Workflows

The sections below list each reusable workflow with usage, inputs, outpus, etc..

For more information about reusable workflows see [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)

**NOTE:** Please ensure that any repositories using these workflows reference them by a major version tag, as opposed to the default branch. Dependabot is able to detect updated tags for reusable workflows. This prevents breaking changes in the called workflows from breaking all caller workflows until the needed changes have been addressed.

Many of our tools follow [Semantic Versioning](https://semver.org/), which means that applying one or more appropriate labels to pull requests is crucial both for determining the next release version of a tool and automatically generating an accurate changelog and release notes using [github-changelog-generator](https://github.com/github-changelog-generator/github-changelog-generator).

### Dependabot auto-merge

The [Dependabot auto-merge](.github/workflows/ensure_label.yml) workflow contains jobs used to gather the [metadata](https://github.com/dependabot/fetch-metadata/tree/main) of a pull request opened by Dependabot, then based on a condition, the pull request is approved and auto-merge enabled, meaning that as soon as all required status checks pass, then the pull request will automatically be merged.

Pre-requisites:

  1. The caller workflow must have an Actions secret called `BOT_GITHUB_TOKEN` with the value being a GitHub token with `repo` permission, and the token be be SSO authorized for the puppetlabs GitHub organization.
  2. The caller repository must have the [auto-merge](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-auto-merge-for-pull-requests-in-your-repository) setting enabled at Settings --> General --> Check "Allow auto-merge".
  3. The caller repository should have a [branch protection rule](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule#creating-a-branch-protection-rule) with at least at least one check in the required status check to pass before merging.
  4. If the caller repository [requires pull request reviews before merging](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#require-pull-request-reviews-before-merging), then the bot account associated with the token used for the `BOT_GITHUB_TOKEN` secret should be, or a member of a team used, in the `CODEOWNERS`.

#### Dependabot auto-merge Example

```yaml
name: Dependabot auto-merge

on: pull_request

jobs:
  dependabot_merge:
    uses: puppetlabs/release-engineering-repo-standards/.github/workflows/dependabot_merge.yml@v1
    secrets: inherit
    with:
      merge-if-minor-or-patch-update: true
```

#### Dependabot auto-merge Secrets

| Secret name | Description | Required | Default value |
|------------|-------------|----------|---------------|
| BOT_GITHUB_TOKEN | string | The token used to approve and enable auto-merge on a pull request. | true | `templates/builders` |

#### Dependabot auto-merge Inputs

| Input name | Type | Description | Required | Default value |
|------------|------|-------------|----------|---------------|
| merge-if-minor-or-patch-update | boolean | Approve and enable auto-merge on the pull request if the dependency update is a minor or patch version bump. | false | false |

#### Dependabot auto-merge Outputs

None

### Ensure label

The [Ensure label](.github/workflows/ensure_label.yml) workflow ensures that at least one label exists on a pull request. If the check fails due to no labels existing, then simply add the appropriate label, and rerun the failed check

#### Ensure label Example

```yaml
name: Ensure label

on: pull_request

jobs:
  label_exists:
    uses: puppetlabs/release-engineering-repo-standards/.github/workflows/ensure_label.yml@v1
```

#### Ensure label Secrets

None

#### Ensure label Inputs

None

#### Ensure label Outputs

None

## Contributing

Submit changes by opening a pull request and assigning the appropriate label.
