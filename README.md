Template repo for syncing C++ CI GitHub workflows and other config.

Repo is intended for use with C++ projects, so most CI GitHub workflows run on
this template will fail; they need a project with C++ source, Catch2 tests,
CMake, Doxygen documentation and so on, configured to pass.

Based on
[process described by Jon Gjengset in this Setting up CI stream](https://www.youtube.com/watch?v=xUH-4y92jPg)

## Usage

From a C++ project run:

```shell
git remote add ci https://github.com/rodneylab/cpp-ci-conf
git fetch ci
git merge --allow-unrelated ci/main
```

This will clone the history of this repo and merge it with yours. You can also
merge updates to these templates (by running the `git merge` step above again).
