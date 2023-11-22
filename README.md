# Release Engineering Repo Standards

Standards and workflows for release engineering repositories

- [Release Engineering Repo Standards](#release-engineering-repo-standards)
  - [Control Workflows](#control-workflows)
    - [Release](#release)
    - [Schedule Release Prep](#schedule-release-prep)
  - [Reusable Workflows](#reusable-workflows)
    - [Auto Release Prep](#auto-release-prep)
      - [Auto Release Prep Example](#auto-release-prep-example)
      - [Auto Release Prep Secrets](#auto-release-prep-secrets)
      - [Auto Release Prep Inputs](#auto-release-prep-inputs)
      - [Auto Release Prep Outputs](#auto-release-prep-outputs)
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

## Control Workflows

The sections below list workflows controlled from this repository.

### Release

The [Release](.github/workflows/release.yml) workflow creates and updates tags and for the reusable workflows themselves, because caller repositories should be referencing these actions via a major version tag according to [GitHub Actions best practices](https://docs.github.com/en/actions/creating-actions/about-custom-actions#good-practices-for-release-management).

If there are backwards incompatible changes to any workflow, then it's important to perform a major version bump, so that any caller workflows can be dealt with appropriately.

The workflow will publish a new release tagging the latest commit, and move the major version tag (For example `v1`), to the latest commit as well.

To perform a manual out of band release, bump the version in `info.json` appropriately based on merged pull requests since the last release and run `./release-prep.sh` to update `CHANGELOG.md`.

### Schedule Release Prep

The [Schedule Release Prep](.github/workflows/schedule_release_prep.yml) workflow runs every Thursday, but uses the current week number modulo 2 in order to determine if it is an odd or even week. If it is an even week (In other words bi-weekly), then for the list of repositories kickoff the Auto Release Prep workflow. In order to not create a "storm" of release prep pull requests all being open at once, it sleeps for a random interval between 1 and 5 minutes between each repository. A `self-hosted` GitHub runner is used due to the random sleep interval, since GitHub hosted runners [bill based on minutes](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions#about-billing-for-github-actions).

Pre-requisites:

  1. The called workflow must have an Actions secret called `BOT_GITHUB_TOKEN` with the value being a GitHub token with `repo` permission, and the token be be SSO authorized for the puppetlabs GitHub organization.
  2. The called repository should contain a `release-prep.sh` script that performs the appropriate preparation steps locally (For example, updating `Gemfile.lock`, or `package-lock.json`, etc. and `CHANGELOG.md`).
  3. The called repository should label pull requests appropriately in order to determine the appropriate next version bump.

## Reusable Workflows

The sections below list each reusable workflow with usage, inputs, outpus, etc..

For more information about reusable workflows see [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)

**NOTE:** Please ensure that any repositories using these workflows reference them by a major version tag, as opposed to the default branch. Dependabot is able to detect updated tags for reusable workflows. This prevents breaking changes in the called workflows from breaking all caller workflows until the needed changes have been addressed.

Many of our tools follow [Semantic Versioning](https://semver.org/), which means that applying one or more appropriate labels to pull requests is crucial both for determining the next release version of a tool and automatically generating an accurate changelog and release notes using [github-changelog-generator](https://github.com/github-changelog-generator/github-changelog-generator).

### Auto Release Prep

The [Auto Release Prep](.github/workflows/auto_release_prep.yml) workflow finds pull requests that have been merged since the last release and determines the appropriate next version bump based on those pull request labels. Next, it updates the semantic version in the file provided by `version-file-path`, commits and pushes to a new branch, then opens a pull request with the maintenance label.

Pre-requisites:

  1. The caller workflow must have an Actions secret called `BOT_GITHUB_TOKEN` with the value being a GitHub token with `repo` permission, and the token be be SSO authorized for the puppetlabs GitHub organization.
  2. The caller repository should contain a `release-prep.sh` script that performs the appropriate preparation steps locally (For example, updating `Gemfile.lock`, or `package-lock.json`, etc. and `CHANGELOG.md`).
  3. The caller repository should label pull requests appropriately in order to determine the appropriate next version bump.

#### Auto Release Prep Example

```yaml
name: Automated release prep

on:
  workflow_dispatch:

jobs:
  release_prep:
    uses: puppetlabs/release-engineering-repo-standards/.github/workflows/auto_release_prep.yml@v1
    secrets: inherit
    with:
      version-file-path: lib/always_be_scheduling/version.rb
```

#### Auto Release Prep Secrets

| Secret name | Type | Description | Required |
|------------|-------------|----------|---------------|
| BOT_GITHUB_TOKEN | string | The token used to git push and open a pull request. | true |

#### Auto Release Prep Inputs

| Input name | Type | Description | Required | Default value |
|------------|------|-------------|----------|---------------|
| version-file-path | string | The path to a file containing a semantic version to update. | true | None |

#### Auto Release Prep Outputs

None

### Dependabot auto-merge

The [Dependabot auto-merge](.github/workflows/ensure_label.yml) workflow contains jobs used to gather the [metadata](https://github.com/dependabot/fetch-metadata/tree/main) of a pull request opened by Dependabot, then based on a condition, the pull request is approved and auto-merge enabled, meaning that as soon as all required status checks pass, then the pull request will automatically be merged. The workflow will also label "patch" dependency bumps with the "bug" label, and "minor" dependency bumps with the "enhancement" label.

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

| Secret name | Type | Description | Required |
|------------|-------------|----------|---------------|
| BOT_GITHUB_TOKEN | string | The token used to approve and enable auto-merge on a pull request. | true |

#### Dependabot auto-merge Inputs

| Input name | Type | Description | Required | Default value |
|------------|------|-------------|----------|---------------|
| merge-if-minor-or-patch-update | boolean | Approve and enable auto-merge on the pull request if the dependency update is a minor or patch version bump. | false | true |

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
