#!/usr/bin/env bash

docker run -it --rm -e CHANGELOG_GITHUB_TOKEN -v $(pwd):/usr/local/src/your-app \
  githubchangeloggenerator/github-changelog-generator:1.16.2 \
  github_changelog_generator --future-release v$(jq -r .version info.json)
