#!/bin/sh

git filter-branch --env-filter '

an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

if [ "$GIT_COMMITTER_EMAIL" = "shadowkyogre@aim.com" ]
then
    cn="Something"
    cm="Something@something.com"
fi
if [ "$GIT_AUTHOR_EMAIL" = "shadowkyogre@aim.com" ]
then
    an="Something"
    am="Something@something.com"
fi

export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'