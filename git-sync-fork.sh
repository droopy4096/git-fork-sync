#!/bin/sh

# Params (env vars):
#   SYNC_ORIGIN (optional) Repo to commit to (Default: origin)
#   SYNC_UPSTREAM (optional) Upstream repo (Default: upstream)
#   SYNC_PR_BRANCH (optional) full PR branch name
#   SYNC_PR_BRANCH_SUFFIX (optional) generate PR branch name based on origin branch plus SUFFIX

ORIGIN=${SYNC_ORIGIN:-"origin"}
UPSTREAM=${SYNC_UPSTREAM:-"upstream"}
PR_BRANCH_SUFFIX=${SYNC_PR_BRANCH_SUFFIX:-"-fix"}

sync_branch(){
  branch_name=$1
  if [ -n "${SYNC_PR_BRANCH}" ]
  then
    PR_BRANCH=${SYNC_PR_BRANCH}
  else
    PR_BRANCH=${branch_name}
  fi
  git checkout --track ${ORIGIN}/${branch_name} && \
  git rebase ${UPSTREAM}/${branch_name} && \
  ( [ -n "$SYNC_PR_BRANCH" -o "$SYNC_PR_BRANCH_SUFFIX" ] && git branch ${branch_name}${PR_BRANCH_SUFFIX}  )
}

cmd=$1
shift 1
$cmd "$@"
