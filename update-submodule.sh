#!/bin/bash

# This script helps to update submodule (in ./emqx) to a different branch with depth=1

set -euo pipefail

remote_ref="${1:-}"
if [ -z "$remote_ref" ]; then
    echo "Usage $0 <remote-branch-name>"
    exit 1
fi
origin_ref="origin/$remote_ref"

git submodule update --init
cd emqx

# rename current branch to another name in case there are extra commits made
current_branch="$(git branch | grep '*' | sed 's#\* ##g')"
if [ "$current_branch" = "$remote_ref" ]; then
    time="$(date --iso-8601=seconds)"
    new_name="${current_branch}-${time}"
    echo "WARN: Renaming current branch to $new_name"
    git branch -m "$new_name"
fi

if git branch -r | grep -q "$origin_ref"; then
    echo "deleting origin/$remote_ref"
    git branch -d -r "origin/$remote_ref"
fi

if ! git remote set-branches origin --add "$remote_ref"; then
    echo "ERROR: failed to set remote tracking branch"
fi

echo "fetching remote"
git fetch --prune --depth=1 origin "$remote_ref"

echo "checking out $origin_ref"
git checkout "remotes/$origin_ref"
