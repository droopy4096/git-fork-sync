#!/bin/sh

# Params (env vars):
#   SYNC_ORIGIN (optional) Repo to commit to (Default: origin)
#   SYNC_UPSTREAM (optional) Upstream repo (Default: upstream)
#   SYNC_PR_BRANCH (optional) full PR branch name
#   SYNC_PR_BRANCH_SUFFIX (optional) generate PR branch name based on origin branch plus SUFFIX

ORIGIN=${SYNC_ORIGIN:-"origin"}
UPSTREAM=${SYNC_UPSTREAM:-"upstream"}
PR_BRANCH_SUFFIX=${SYNC_PR_BRANCH_SUFFIX:-"-fix"}
SAVED_BRANCHES=${SYNC_SAVED_BRANCHES:-"${UPSTREAM}-branches"}
SYNC_REBASE_OPTIONS=${SYNC_REBASE_OPTIONS:-""}

sync_branch(){
  branch_name=$1
  if [ -n "${SYNC_PR_BRANCH}" ]
  then
    PR_BRANCH=${SYNC_PR_BRANCH}
  else
    PR_BRANCH=${branch_name}
  fi

  if git checkout --track ${ORIGIN}/${branch_name}
  then
    echo ""
  else
    if ( list_branches ${ORIGIN} | grep ${branch_name} )
    then
      # we already have this branch... we're OK, lets just pull it
      git checkout ${branch_name}
      git pull
    fi
  fi && \
  git rebase ${SYNC_REBASE_OPTIONS} ${UPSTREAM}/${branch_name} && \
  ( [ -n "$SYNC_PR_BRANCH" -o "$SYNC_PR_BRANCH_SUFFIX" ] && git branch ${branch_name}${PR_BRANCH_SUFFIX}  )
}

list_branches(){
  repo=${1}
  git remote show ${repo} | awk 'BEGIN{track=0;}/Remote branches:/ {track=2;} /Local/ {track=0;} track {if(track>1) {track=1} else {print $1;}}'
}

save_upstream_branches(){
  list_branches ${UPSTREAM} > ${SAVED_BRANCHES}
}

pop_branch(){
  # organize and create temp file
  SAVED_BRANCHES_DIR=${SAVED_BRANCHES%/*}
  [ "${SAVED_BRANCHES_DIR}" == "${SAVED_BRANCHES}" ] && SAVED_BRANCHES_DIR="."
  SAVED_BRANCHES_FILE=${SAVED_BRANCHES##*/}
  SAVED_BRANCHES_TMP=$(mktemp --tmpdir=${SAVED_BRANCHES_DIR} "${SAVED_BRANCHES_FILE}.XXXXX")

  cp ${SAVED_BRANCHES} ${SAVED_BRANCHES_TMP}
  CURRENT_BRANCH=$(head -n 1 ${SAVED_BRANCHES_TMP})
  tail -n +2 ${SAVED_BRANCHES_TMP} > ${SAVED_BRANCHES}
  rm ${SAVED_BRANCHES_TMP}
  echo ${CURRENT_BRANCH}
}

sync_next(){
  branch_name=$(pop_branch)
  sync_branch ${branch_name}
}

cmd=$1
shift 1
$cmd "$@"
