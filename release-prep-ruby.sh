#!/usr/bin/env bash

# Update Gemfile.lock
docker run -t --rm \
  -v $(pwd):/app \
  ruby:3.2.2 \
  /bin/bash -c 'apt-get update -qq && apt-get install -y --no-install-recommends git make netbase && cd /app && gem install bundler && bundle install --jobs 3; echo "LOCK_FILE_UPDATE_EXIT_CODE=$?"'

docker run -t --rm -e CHANGELOG_GITHUB_TOKEN -v $(pwd):/usr/local/src/your-app \
  githubchangeloggenerator/github-changelog-generator:1.16.2 \
  github_changelog_generator --future-release $(grep VERSION lib/project/version.rb |rev |cut -d "'" -f 2 |rev)