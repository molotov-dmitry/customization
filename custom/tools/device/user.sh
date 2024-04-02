#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

#### Configure Git =============================================================

GITLAB_SERVER='git.rczifort.local'
GITLAB_IP='172.16.56.22'
LDAP_LOGIN='devops'
LDAP_PASSWORD='11111111'

if ispkginstalled git
then

    #### Add credentials -------------------------------------------------------

    if ! grep -qs "https://${LDAP_LOGIN}:${LDAP_PASSWORD}@${GITLAB_IP}" "$HOME/.git-credentials"
    then
        echo "https://${LDAP_LOGIN}:${LDAP_PASSWORD}@${GITLAB_IP}" >> "$HOME/.git-credentials"
    fi

    if ! grep -qs "https://${LDAP_LOGIN}:${LDAP_PASSWORD}@${GITLAB_SERVER}" "$HOME/.git-credentials"
    then
        echo "https://${LDAP_LOGIN}:${LDAP_PASSWORD}@${GITLAB_SERVER}" >> "$HOME/.git-credentials"
    fi

    #### Add user information --------------------------------------------------

    git config --global "credential.https://${GITLAB_SERVER}.username" "${LDAP_LOGIN}"
    git config --global "credential.https://${GITLAB_IP}.username"     "${LDAP_LOGIN}"

    #### -----------------------------------------------------------------------

fi

#### Configure SSH =============================================================

#### Generate SSH private and public key pair ----------------------------------

if [[ ! -f "${HOME}/.ssh/id_rsa" ]]
then
    ssh-keygen -q -t rsa -N '' -f "${HOME}/.ssh/id_rsa" 2>/dev/null <<< y >/dev/null
fi
