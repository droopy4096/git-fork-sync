# git-fork-sync
Synchronize your git fork with upstream

## Usage

Simple use (no PR branch generation):

```shell
  export SAVED_BRANCHES=my_file
  sh -x git-sync-fork.sh save_upstream_branches
  # edit ${SAVED_BRANCHES}
  sh -x git-sync-fork.sh next_sync
  # do whatever needs to be done before next sync
  # ...
  # git branches -v
  sh -x git-sync-fork.sh next_sync
```

More complex use:

```shell
  export SAVED_BRANCHES=my_file
  export PR_BRANCH_SUFFIX="-my-fix"
  sh -x git-sync-fork.sh save_upstream_branches
  # edit ${SAVED_BRANCHES}
  sh -x git-sync-fork.sh next_sync
  # do whatever needs to be done before next sync
  # ...
  # git branches -v
  # note that you have two branches checked out - original and <original>-my-fix
  sh -x git-sync-fork.sh next_sync
```
