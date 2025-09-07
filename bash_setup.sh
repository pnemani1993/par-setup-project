#!/usr/bin/env bash

### Setup of the following: ###
# 1. Save the following in an executable shell script and 
#    append the `~/.bashrc` file with `source <script>.sh`.
#    (OR)
# 2. Save the following directly in the `~/.bashrc` or `~/.bash_profile` file.
### End of Setup

### Start region: Setting up aliases
alias mvnTree='mvn dependency:tree | code -'
alias gitMaster="git checkout $(git branch --remotes | grep HEAD | sed 's/.*-> //g') && git pull"
alias nocommit='git commit --amend --no-edit && git push --force'
alias chrome='open -a /Applications/"Google Chrome.app"'
alias gitSave="git stash store $(git stash create) -m $(date)"

export DEV_DIR="${HOME}/dev"

if [[ ! -d "${DEV_DIR}" ]]; then 
    mkdir "${DEV_DIR}"
fi

### End region

### Start region: Installing required dependencies
function install_dependencies {
    if [ -n "$(command -v fnm)"]; then
        # Download and install fnm:
        curl -o- https://fnm.vercel.app/install | bash;
        # Download and install Node.js:
        fnm install --lts;
    fi
    # Downloading fzf
    if [ -n "$(command -v fzf)" ]; then 
        brew install fzf;
    fi
    if [ -n "$(command -v gum)" ]; then 
        brew install gum;
    fi
    if [-n "$(command -v sdk)" ]; then
        curl -s "https://get.sdkman.io" | bash;
    fi
}
###


### Start region: github repos related script

function _selected() {
    _select="$(find "${DEV_DIR}" -maxdepth 4 -name .git -exec dirname {} \; | fzf);
    echo "${_select}";
    return 0;
}

function ,code() {
    _selector=$(_selected);
    if [ -z "$_selector" ]; then 
        echo "No directory selected. Exiting...";
        return 1;
    fi
    code "${_selector}";
    return 0;
}

function ,cd() {
    _selector=$(_selected);
    if [ -z "$_selector" ]; then 
        echo "No directory selected. Exiting...";
        return 1;
    fi
    cd "${_selector}";
    return 0;
}

function ,web() {
    if [ -d ".git" ]; then
        _url=$(git config --get remote.origin.url | sed 's/git@/https:\/\//g' | sed 's/\.git//g');
        open -a /Applications/"Google Chrome.app" "${_url}";
        return 0;
    elif [ -n "$1" ]; then
        open -a /Applications/"Google Chrome.app" "$1";
        return 0;
    else
        echo "Opening google.com";
        open -a /Applications/"Google Chrome.app" https://www.google.com;
        return 0;
    fi
}

function ,clone() {
    curr_location=$(pwd)
    if [[ "$1" =~ ^https:\/\/ ]]; then
        loc="$1";
        loc=$(echo "${loc}" | sed 's/^https:\/\///g' | sed 's/\.git$//g' | cut -d "/" -f 1,2);
        if [ ! -d "${DEV_DIR}/${loc}" ]; then
            mkdir -p "${DEV_DIR}/${loc}";
        fi
        cd "${DEV_DIR}/${loc}"
        git clone "$1";
        cd "${curr_location};
        return 0;
    elif [[ "$1" =~ ^git@ ]]; then
        loc="$1";
        loc=$(echo "${loc}" | sed 's/^git@//g' | sed 's/\.git$//g' | sed 's/:/\//g' | cut -d "/" -f 1,2)
        if [ ! -d "${DEV_DIR}/${loc}" ]; then
            mkdir -p "${DEV_DIR}/${loc}";
        fi
        cd "${DEV_DIR}/${loc}"
        git clone "$1";
        cd "${curr_location};
        return 0;
    else 
        echo "Invalid Github URL. Exiting...";
        return -1;
}
### End region
