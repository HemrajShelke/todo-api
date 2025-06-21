#!/bin/sh
git filter-branch --force --env-filter '
    export GIT_AUTHOR_NAME="HemrajShelke"
    export GIT_AUTHOR_EMAIL="160580934+HemrajShelke@users.noreply.github.com"
    export GIT_COMMITTER_NAME="HemrajShelke"
    export GIT_COMMITTER_EMAIL="160580934+HemrajShelke@users.noreply.github.com"
' --tag-name-filter cat -- --branches --tags
