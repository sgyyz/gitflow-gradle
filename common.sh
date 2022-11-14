info() {
  echo ">> $1"
}

git_compare_branches() {
	local commit1=$(git rev-parse "$1")
	local commit2=$(git rev-parse "$2")

	if [ "$commit1" != "$commit2" ]; then
		local base=$(git merge-base "$commit1" "$commit2")
		if [ $? -ne 0 ]; then
			return 4
		elif [ "$commit1" = "$base" ]; then
			return 1
		elif [ "$commit2" = "$base" ]; then
			return 2
		else
			return 3
		fi
	else
		return 0
	fi
}

compare_and_check() {
	git_compare_branches "$(git_current_branch)" "origin/$(git_current_branch)"
  local status=$?
  if [ $status -eq 2 ]; then
    info "ahead"
    exit 0
  elif [ $status -eq 1 ]; then
    info "behind"
    exit 0
  fi
}

git_current_branch() {
  git branch --no-color | grep '^\* ' | grep -v 'no branch' | sed 's/^* //g'
}

read_gradle_version() {
	cat gradle.properties | sed s/version=// | head -n 1
}

update_gradle_version() {
	local next_version=$1
	sed -i '' 's/^version=.*$/version='"$1"'/g' gradle.properties
}

parse_snapshot_version() {
	echo $1 | sed s/-SNAPSHOT// | head -n 1
}

upgrade_minor_version() {
	local version=$1
	a=( ${version//./ } )
	((a[1]++))
	a[2]=0
	echo "${a[0]}.${a[1]}.${a[2]}"
}