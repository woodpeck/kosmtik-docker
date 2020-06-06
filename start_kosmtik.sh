#! /usr/bin/env bash

set -euo pipefail

KOSMTIK_VERSION=${KOSMTIK_VERSION:-86db5f319fc6e710db977665f8a2734b449db9b6}

function print_help {
    echo "Usage: $0 [OPTIONS] DIRECTORY MML_FILE"
    echo ""
    echo "Options:"
    echo "  -p=ARG, --port=ARG  Port where Kosmtik should listen at (default 6789)"
    echo "  -d=ARG, --dir=ARG   Directory to mount at /mapstyle where all resources"
    echo "                      required by the map style. (required)"
    echo "  -m=ARG, --mml=ARG   Path to the .mml file relative to the path provided"
    echo "                      by --dir. (required)"
    exit 1
}


OPTS=`getopt -o p:d:m:h --long port:dir:mml:,help -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then
    echo "Failed parsing options." >&2
    print_help
fi

PORT=6789
DIRECTORY=""
MML_FILE=""

eval set -- "$OPTS"

while true; do
    case "$1" in
        -p | --port ) PORTMAPPING=$2; shift; shift ;;
        -d | --dir ) DIRECTORY=$2; shift; shift ;;
        -m | --mml ) MML_FILE=$2; shift; shift ;;
        -h | --help )    print_help; exit ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

if [ "$DIRECTORY" == "" ] || [ "$MML_FILE" == "" ] ; then
    echo "ERROR: Missing options --dir and/or --mml."
    print_help
fi

# Get path to PostgreSQL socket
# See also https://www.jujens.eu/posts/en/2017/Feb/15/docker-unix-socket/
PG_SOCKET_DIR=$(pg_conftool show unix_socket_directories | sed -Ee "s/unix_socket_directories = '([^']+)'$/\1/g")
PG_PORT=$(pg_conftool show port | sed -Ee "s/port = '([^']+)'$/\1/g")
PG_SOCKET_FILENAME="/.s.PGSQL.$PG_PORT"
PG_SOCKET_PATH="$PG_SOCKET_DIR/$PG_SOCKET_FILENAME"

# Check if MML_FILE points is resolvable as path relative to DIRECTORY and points to a file or symlink.
# First, check if MML_FILE starts with a slash to denote an absolute path which would be wrong.
if [ $(echo "$MML_FILE" | sed -Ee "s,^/.*$,/,g") == "/" ] ; then
    echo "ERROR: $MML_FILE starts with a slash. The path should be relative to $DIRECTORY and should be a relative path!"
    exit 1
fi
# Ensure that MML_FILE does not contain .. to avoid directory traversal issues.
TEST_RESULT=$(echo "$MML_FILE" | grep -Eoe "(^|/)\.\.($|/)") || true
if [ "$TEST_RESULT" != "" ] ; then
    echo "ERROR: Illegal directory traversal in $MML_FILE detected."
    exit 1
fi
MML_PATH_FULL=$DIRECTORY/$MML_FILE
if [ ! -f "$MML_PATH_FULL" ] && [ ! -L "$MML_PATH_FULL" ] ; then
    echo "ERROR: $MML_FILE is not resolveable as path relative to $DIRECTORY"
    exit 1
fi

SCRIPTDIR=$(dirname $0)

echo "Starting container"
docker run \
    --attach=STDIN --attach=STDOUT --attach=STDERR \
    --interactive=true --tty=true \
    --network=host \
    --expose=$PORT \
    --user=$(id -u ${USER}):$(id -g ${USER}) \
    --mount=type=bind,source=$PG_SOCKET_DIR,destination=/var/run/postgresql,ro=true \
    --mount=type=bind,source=$DIRECTORY,destination=/mapstyle,ro=true \
    --env="MML_FILE=$MML_FILE" \
    --env="PORT=$PORT" \
    kosmtik:$KOSMTIK_VERSION || true

CONTAINER_ID=$(docker container ls -a -q -f ancestor=kosmtik:$KOSMTIK_VERSION)

echo "Removing all Kosmtik containers: $CONTAINER_ID"
docker container rm $CONTAINER_ID
