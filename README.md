## Gitflow Gradle

This is used for the general Gradle project to use the standard Git Flow branch model to do the release/hotfix.
The highlight of this repository is help us to update the `gradle.properties` version for release/hotfix.

### Usage

#### Release

```shell
$ ./release.sh start
$ git checkout release/xxxx

## Add your commits to the release branch
$ ./release.sh finish
```

#### Hotfix

```shell
$ git checkout main
$ ./hotfix.sh start
$ git checkout hotfix/xxxx

## Add your commits to the hotfix branch
$ ./hotfix.sh finish # default will merge back to the main/develop branch
## Or
$ ./hotfix.sh finish release/xxx # will merge back to the main/release branch
```