#!/bin/bash
source $(dirname "$0")/common.sh

start() {
  info "hotfix start"

  local main_branch=$(git_current_branch)
  
  if [[ "$main_branch" != main ]]; then
    info "Please checkout the main branch"
    exit 0
  fi

  compare_and_check

  local release_version="$(read_gradle_version)"
  local hotfix_version="$(upgrade_patch_version $release_version)"
  info "create hotfix/$hotfix_version"
  update_gradle_version "${hotfix_version}-SNAPSHOT"
  git add .
  git commit -m "Update version for hotfix"
  git checkout -b hotfix/$hotfix_version
  git push origin hotfix/$hotfix_version
}

finish() {
  info "hotfix finish"

  local hotfix_branch=$(git_current_branch)

  if [[ "$hotfix_branch" != hotfix* ]]; then
    info "Please checkout the hotfix branch"
    exit 0
  fi

  compare_and_check

  local snapshot_version="$(read_gradle_version)"
  local version="$(parse_snapshot_version $snapshot_version)"
  update_gradle_version $version
  git add .
  git commit -m "Update version for hotfix"

  git checkout main
  git merge --no-ff -m "Merge from $hotfix_branch" $hotfix_branch

  git tag -a $version -m "Tag for $version"

  git push origin main
  git push origin $version

  target_branch="develop"
  if [ "$2" ]; then
    target_branch=$2
  fi

  git checkout $target_branch
  local target_version="$(read_gradle_version)"

  git checkout $hotfix_branch
  update_gradle_version $target_version
  git add .
  git commit -m "Update to current development version"

  git checkout $target_branch
  git merge --no-ff -m "Merge $hotfix_branch back to develop" $hotfix_branch
  git push origin $target_branch

  git branch -D $hotfix_branch
  git push origin -d $hotfix_branch
}

$1