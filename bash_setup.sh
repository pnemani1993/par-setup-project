#!/usr/bin/env bash

### Start region: Setting up aliases
alias mvnTree='mvn dependency:tree | code -'
alias gitMaster="git checkout $(git branch --remotes | grep HEAD | sed 's/.*-> //g') && git pull"
alias nocommit='git commit --amend --no-edit && git push --force'
### End region