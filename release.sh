#!/bin/bash
source $(dirname "$0")/common.sh

start() {
  info "release start"

  info "checkout to the develop branch"
  git checkout develop

  compare_and_check

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

  if [[ "$release_branch" != release* ]]; then
    info "Please checkout the release branch"
    exit 0
  fi

  compare_and_check

  local snapshot_version="$(read_gradle_version)"
  local version="$(parse_snapshot_version $snapshot_version)"
  update_gradle_version $version
  git add .
  git commit -m "Update version for release"

  git checkout main
  git merge --no-ff -m "Merge from $release_branch" $release_branch

  git tag -a $version -m "Tag for $version"

  git push origin main
  git push origin $version

  git checkout develop
  local develop_version="$(read_gradle_version)"

  git checkout $release_branch
  update_gradle_version $develop_version
  git add .
  git commit -m "Update to current development version"

  git checkout develop
  git merge --no-ff -m "Merge $release_branch back to develop" $release_branch
  git push origin develop

  git branch -D $release_branch
  git push origin -d $release_branch
}

$1