#!/bin/bash
#
# This file is free software, distributed under the GPL License.
#
# Setup dev environment for Ubuntu 14.04/16.04 x86_64(NO i386) on Bash(NO sh, or zsh)
#
cd "$(dirname "$0")"

declare -r GITLAB_HOST=github.com
declare -r GITLAB_URL=https://$GITLAB_HOST
declare -r REPO_URL=https://$GITLAB_HOST/jiemolabs/dev-setup.git

usage() {
    cat <<EOF
EOF
}

main() {
    if ! grep -qiE 'xenial|trusty' /etc/os-release; then
        echo "Sorry! we don't currently support that distro."
        exit 1
    fi

    set -o errexit
    sudo apt-get install --yes git python-virtualenv python-pip python-dev libffi-dev libssl-dev
    set +o errexit

    # if we are not inside the repo
    if ! git remote -v &>/dev/null; then
        if [[ ! -e ~/.ssh/id_rsa ]]; then
            ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
        fi
        if ! ssh -o PasswordAuthentication=no -T git@$GITLAB_HOST &>/dev/null; then
            echo "Add following public key to $GITLAB_URL/profile/keys"
            cat ~/.ssh/id_rsa.pub
            read -r -t 30 -p "ENTER to continue"
            if [[ $? -gt 128 ]]; then
                echo -e "\nAbort..."
                exit 1
            fi
        fi

        set -o errexit
        git clone $REPO_URL
    fi

    #sudo --set-home pip install --upgrade setuptools
    # https://github.com/rdickert/project-quicksilver/issues/6#issuecomment-20822097
    pip install --user ansible markupsafe
    set -o errexit
    # cd the repo we cloned in last step
    if [[ -e dev-setup ]]; then
        cd dev-setup
    fi
    sudo apt-get install --yes sshpass python-pip
    export PATH=$PATH:$HOME/.local/bin
    set +o errexit

    local action="$1"

    if [[ $action == "--mis" || $action == "--all" ]]; then
        if [[ ! -e ~/.davfs2/secrets ]]; then
            ~/.local/bin/ansible-playbook -i 127.0.0.1, --connection=local mis.yml
        fi
    fi

    ~/.local/bin/ansible-playbook -i 127.0.0.1, --connection=local common.yml

    if [[ $action == "--dev" || $action == "--all" ]]; then
        ~/.local/bin/ansible-playbook -i 127.0.0.1, --connection=local dev.yml
    fi

    if [[ $action == "--desktop" || $action == "--all" ]]; then
        ~/.local/bin/ansible-playbook -i 127.0.0.1, --connection=local desktop.yml
    fi
}

main "$@"

exit 0
