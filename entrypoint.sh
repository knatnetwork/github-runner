#!/bin/bash
set -euo pipefail

if [ -n "${ADDITIONAL_PACKAGES}" ]; then
    TO_BE_INSTALLED=$(echo "${ADDITIONAL_PACKAGES}" | tr "," " ")
    echo "Installing additional packages: ${TO_BE_INSTALLED}"
    # Package names come from the operator-supplied list and must be split on whitespace.
    # shellcheck disable=SC2086
    sudo apt-get update && sudo apt-get install -y ${TO_BE_INSTALLED} && sudo apt-get clean
fi

if [ -z "${RUNNER_NAME}" ]; then
    RUNNER_NAME=$(hostname)
fi

if [ -z "${RUNNER_WORKDIR}" ]; then
    RUNNER_WORKDIR="_work"
fi

if [[ "${RUNNER_REGISTER_TO}" == */* ]]; then
    REGISTRATION_TOKEN_PATH="/repo/${RUNNER_REGISTER_TO}/registration-token"
    REMOVE_TOKEN_PATH="/repo/${RUNNER_REGISTER_TO}/remove-token"
else
    REGISTRATION_TOKEN_PATH="/${RUNNER_REGISTER_TO}/registration-token"
    REMOVE_TOKEN_PATH="/${RUNNER_REGISTER_TO}/remove-token"
fi

# ADDITIONAL_FLAGS is an optional list of config.sh arguments, such as --ephemeral.
# shellcheck disable=SC2086
./config.sh --unattended \
    --url "https://github.com/${RUNNER_REGISTER_TO}" \
    --token "$(curl -fsS "${KMS_SERVER_ADDR}${REGISTRATION_TOKEN_PATH}")" \
    --name "${RUNNER_NAME}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "${RUNNER_LABELS}" \
    --disableupdate \
    ${ADDITIONAL_FLAGS}

remove() {
    ./config.sh remove --token "$(curl -fsS "${KMS_SERVER_ADDR}${REMOVE_TOKEN_PATH}")" || true
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./runsvc.sh "$@" &

wait $!
