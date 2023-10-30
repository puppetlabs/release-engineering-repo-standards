# Release Engineering Repo Standards

Standards and workflows for release engineering repositories

- [Release Engineering Repo Standards](#release-engineering-repo-standards)
  - [Workflows](#workflows)
    - [Ensure label](#ensure-label)
    - [Example](#example)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
  - [Contributing](#contributing)

## Workflows

The sections below list each reusable workflow with usage, inputs, outpus, etc..

For more information about reusable workflows see [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)

**NOTE:** Please ensure that any repositories using these workflows reference them by a major version tag, as opposed to the default branch. Dependabot is able to detect updated tags for reusable workflows. This prevents breaking changes in the called workflows from breaking all caller workflows until the needed changes have been addressed.

### Ensure label

Many of our tools follow [Semantic Versioning](https://semver.org/), which means that applying one or more appropriate labels to pull requests is crucial both for determining the next release version of a tool and automatically generating an accurate changelog and release notes using [github-changelog-generator](https://github.com/github-changelog-generator/github-changelog-generator).

The [Ensure label](.github/workflows/ensure_label.yml) ensures that at least one label exists on a pull request. If the check fails due to no labels existing, then simply add the appropriate label, and rerun the failed check

### Example

```yaml
name: Ensure label

on: pull_request

jobs:
  label_exists:
    uses: puppetlabs/release-engineering-repo-standards/.github/workflows/ensure_label.yml@v1
```

### Inputs

None

### Outputs

None

## Contributing

Submit changes by opening a pull request and assigning the appropriate label.
