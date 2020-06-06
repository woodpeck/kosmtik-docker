#! /usr/bin/env bash

if [ -z "$MML_FILE" ]; then
    echo "ERROR: Environment variable MML_FILE is not set. It should contain the path to the .mml file relative to the directory mounted in the container at /mnt/mapstyle"
    exit 1
fi

set -euo pipefail

./index.js serve --mapnik-version 3.0.20 --port $PORT "/mapstyle/$MML_FILE"
