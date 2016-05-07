#!/bin/bash
#
# Copyright (C) 2016 by Lele Long <longlele@jiemo.io>
# This file is free software, distributed under the GPL License.
#
# Setup dev environment for Ubuntu 14.04/16.04 x86_64(NO i386) on Bash(NO sh, or zsh)
#
cd "$(dirname "$0")"

declare -r GITLAB_HOST=git.jiemo.io
declare -r GITLAB_URL=https://$GITLAB_HOST
declare -r REPO_URL=git@$GITLAB_HOST:infra/dev-setup

usage() {
    cat <<EOF
EOF
}

main() {
    set -o errexit
    sudo apt-get install --yes git python-virtualenv python-pip python-dev libffi-dev libssl-dev
    set +o errexit

    # if we are not inside the repo
    if ! git remote -v >/dev/null; then
        if [[ ! -e ~/.ssh/id_rsa ]]; then
            ssh-keygen -t rsa -N "" ~/.ssh/id_rsa
        fi
        if ! ssh -o PasswordAuthentication=no -T git@$GITLAB_HOST; then
            echo "Add following public key to $GITLAB_URL/profile/keys"
            cat ~/.ssh/id_rsa.pub
            read -t 30 -p "ENTER to continue"
            if [[ $? -gt 128 ]]; then
                echo -e "\nAbort..."
                exit 1
            fi
        fi

        git clone $REPO_URL
    fi

    set -o errexit
    # cd the repo we cloned in last step
    if [[ -e dev-setup ]]; then
        cd dev-setup
    fi
    sudo apt-get install --yes sshpass
    pip install --user ansible
    set +o errexit

    ~/.local/bin/ansible-playbook common.yml
    local action="$1"
    if [[ $action == "--dev" || $action == "--all" ]]; then
        ~/.local/bin/ansible-playbook dev.yml
    fi

    if [[ $action == "--desktop" || $action == "--all" ]]; then
        ~/.local/bin/ansible-playbook desktop.yml
    fi
}

main "$@"

exit 0
