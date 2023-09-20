#!/bin/bash

if [ -n "${ADDITIONAL_PACKAGES}" ]; then
    TO_BE_INSTALLED=$(echo ${ADDITIONAL_PACKAGES} | tr "," " " )
    echo "Installing additional packages: ${TO_BE_INSTALLED}"
    sudo apt-get update && sudo apt-get install -y ${TO_BE_INSTALLED} && sudo apt-get clean
fi

if [ -z "${RUNNER_NAME}" ]; then
    RUNNER_NAME=$(hostname)
fi

if [[ "${RUNNER_REGISTER_TO}" == *\/* ]]; then
    # Contain "/", to Repo
    ./config.sh --unattended --url https://github.com/${RUNNER_REGISTER_TO} --token $(curl ${KMS_SERVER_ADDR}/repo/${RUNNER_REGISTER_TO}/registration-token) ${ADDITIONAL_FLAGS} --labels "${RUNNER_LABELS}" --disableupdate
else
    # Not contain "/", to Org
    ./config.sh --unattended --url https://github.com/${RUNNER_REGISTER_TO} --token $(curl ${KMS_SERVER_ADDR}/${RUNNER_REGISTER_TO}/registration-token) ${ADDITIONAL_FLAGS} --labels "${RUNNER_LABELS}" --disableupdate
fi

remove() {
if [[ "${RUNNER_REGISTER_TO}" == *\/* ]]; then
    # Contain "/", to Repo
    ./config.sh --unattended remove --token $(curl ${KMS_SERVER_ADDR}/repo/${RUNNER_REGISTER_TO}/remove-token)
else
    # Not contain "/", to Org
    ./config.sh --unattended remove --token $(curl ${KMS_SERVER_ADDR}/${RUNNER_REGISTER_TO}/remove-token)
fi
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./runsvc.sh "$*" &

wait $!
