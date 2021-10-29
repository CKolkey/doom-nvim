#!/usr/bin/env bash

# This script updates pinned dependencies in ../lua/doom/modules/init.lua
# It uses grep to find instances of packer.use, uses the repository url to fetch the latest commit sha, and modifies the values
# Dependencies
# perl -- used for Regexing the repository <account>/<repo_name> with capture groups to extract inner text
# grep -- Used for regexing the use({}) block with line numbers
# 

index=0
repo_regex='"([^"]+)"'
pin_commit_regex='pin_commit[(][^()]*[)]'

repo=''
latest_commit=''

while read -r line; do
  if [[ $index -eq 1 ]]; then
    # Get the repository name as `<username>/reponame`
    if [[ $line =~ $repo_regex ]]; then # Regex $line against $repo_regex
      repo="${BASH_REMATCH[1]}" # Get first capture group
      echo ""
      echo "Updating $repo:"

      # Sometimes the github api requests will fail, in which case we need to re-try after a delay.
      while [ -z "$latest_commit" ]; do
        # Get the commit sha from github
        api_result=`curl -s \
          -H "Accept: application/vnd.github.v3+json" \
          https://api.github.com/repos/$repo/commits?per_page=1`

        is_array=`echo $api_result | jq -r 'if type=="array" then "yes" else "no" end'`

        # If there's an error, log it and wait 30 seconds
        if [ "$is_array" = "no" ]; then
          echo "- Github API Error: $( echo "$api_result" | jq -r .message )"
          echo "- Waiting 30 seconds before trying again..."
          sleep 30
        else
          latest_commit=`echo $api_result | jq -r .[0].sha`
        fi

      done
    else
      echo " - ERROR: No repo name for $line :("
    fi
  fi

  if [[ $index -eq 2 ]]; then # 
    if [ ! -z "$repo" ] && [ ! -z "$latest_commit" ] && [[ $line =~ $pin_commit_regex ]]; then 
      line_number=`echo $line | awk -F "-" '{print $1}'`
      sed -r -i -- "${line_number}s/pin_commit[(][^()]*[)]/pin_commit('${latest_commit}')/" "../lua/doom/modules/init.lua"
      echo " - Updated to $latest_commit"
    else
      echo " - ERROR: Did not update $repo because \`commit = pin_commit('...')\` was not immediately after the repo name."
    fi
  fi

  let index+=1
  if [[ $line == '--' ]]; then
    sleep 5
    index=0
    repo=''
    latest_commit=''
  fi
done < <(grep -n "use\(\{" -A 2 -E ../lua/doom/modules/init.lua)


