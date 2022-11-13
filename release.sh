# release start function
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
