#!/bin/bash
# release start function
# 0. check if there any local/remote release branch
# 1. checkout to develop
# 2. check remote vs local, if it is synced or has any local change
# 3. create the release branch based on the develop branch
# 4. update the develop branch to the next SNAPSHOT version
# 5. push the develop branch to the remote
# 6. push the release branch to the remote

# release finish function
# 1. checkout the release branch, it should only has one
# 2. check remote vs local for:
#   2.1. release branch
#   2.2. develop branch
#   2.3. master branch
# 3. update the release branch version without SNAPSHOT
# 4. checkout master and then merge --no-ff release branch
# 5. tag the master branch with the version
# 6. checkout the release branch and update the version same as the develop branch
# 7. checkout develop and merge --no-ff release branch
# 8. push master
# 9. push develop
# 10. delete local and remote release branch
source $(dirname "$0")/common.sh

start() {
  info "release start"

  info "checkout to the develop branch"
  git checkout develop

  git_compare_branches "$(git_current_branch)" "origin/$(git_current_branch)"
  local status=$?
  if [ $status -eq 2 ]; then
    info "ahead"
    exit 0
  elif [ $status -eq 1 ]; then
    info "behind"
    exit 0
  fi

  local snapshot_version="$(read_gradle_version)"
  local version="$(parse_snapshot_version $snapshot_version)"
  info "create release/$version"
  git checkout -b release/$version
  git push origin release/$version

  git checkout develop
  local next_develop_version="$(upgrade_minor_version $version)-SNAPSHOT"
  update_gradle_version $next_develop_version
  git add .
  git commit -m "Update to next development version"
  git push origin develop
}

finish() {
  info "release finish"

  local release_branch=$(git_current_branch)

  if [[ $release_branch != "release/*" ]]; then
    info "Please checkout the release branch"
    exit 0
  fi

  ## update the version without snapshot
  local snapshot_version="$(read_gradle_version)"
  local version="$(parse_snapshot_version $snapshot_version)"
  update_gradle_version $version
  git add .
  git commit -m "Update version for release"

  ## merge to the main
  git checkout main
  git merge --no-ff $release_branch

  ## tag the main
  git tag -a $version -m "Tag for $version"

  git push origin main
  git push origin $version

  ## update it same as the develop version
  git checkout develop
  local develop_version="$(read_gradle_version)"

  ## checkout to the release branch 
  git checkout $release_branch
  update_gradle_version $develop_version
  git add .
  git commit -m "Update to current development version"

  ## merge it back to develop
  git merge --no-ff $release_branch
  git push origin develop

  ## delete the release branch local/remote
  git branch -D $release_branch
  git push origin -d $release_branch
}

$1