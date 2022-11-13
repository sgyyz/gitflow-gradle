# hotfix start function
# 1. checkout to master
# 2. check remote vs local, if it is synced or has any local change
# 3. create the hotfix branch based on the master branch, with the patch version + 1 with SNAPSHOT
# 4. push the hotfix branch to the remote

# hotfix finish function
# 1. checkout the hotfix branch, it should only has one
# 2. check remote vs local for:
#   2.1. release branch(if has it)
#   2.2. develop branch
#   2.3. master branch
# 3. update the hotfix branch version without SNAPSHOT
# 4. checkout master and then merge --no-ff hotfix branch
# 5. tag the master branch with the version
# 6. check the hotfix branch and update the version same as the release(if has it)/develop branch
# 7. checkout release(if has it)/develop and merge --no-ff release branch
# 8. push master
# 9. push release(if has it)/develop
# 10. delete local and remote hotfix branch
