#! /usr/bin/env bash

set -euo pipefail

ZIP_URL_BASE=${ZIP_URL_BASE:-https://github.com/kosmtik/kosmtik/archive}
BRANCH_TAG=${BRANCH_TAG:-6fbf71e0a83fd1171611fa25b2ef777bf7a62f20}
BRANCH_TAG_IN_ZIP=${BRANCH_TAG_IN_ZIP:-6fbf71e0a83fd1171611fa25b2ef777bf7a62f20}

SCRIPTDIR=$(dirname $0)

cd $SCRIPTDIR

echo "Building image kosmtik:$BRANCH_TAG"

docker build \
    --build-arg=ZIP_URL_BASE=$ZIP_URL_BASE \
    --build-arg=BRANCH_TAG=$BRANCH_TAG \
    --build-arg=BRANCH_TAG_IN_ZIP=$BRANCH_TAG_IN_ZIP \
    --build-arg=HOST_UID=$(id -u) \
    --build-arg=HOST_GID=$(id -g) \
    --build-arg=HOST_USER=$USER \
    --tag=kosmtik:$BRANCH_TAG \
    $SCRIPTDIR

echo "SUCCESS: Built image kosmtik:$BRANCH_TAG"
