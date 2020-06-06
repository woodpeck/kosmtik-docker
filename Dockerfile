FROM node:12-buster
# Node 9 is required because node-mapnik fails to build with later releases of NodeJS

ARG ZIP_URL_BASE
ARG BRANCH_TAG
ARG BRANCH_TAG_IN_ZIP
ARG HOST_USER
ARG HOT_UID
ARG HOST_GID

USER $HOST_UID:$HOST_GID

COPY run.sh /

# It is required that the user running Kosmtik owns the files. I don't know why but it seems that
# it depends on that. Well it's NodeJS.
# In addition, it is required to change the symbolic name of the user called "node" by the base
# image to the name used by the user startig the container for PostgreSQL peer authentication to
# work.
RUN apt-get update && apt-get install -y wget libmapnik-dev vim && \
    mkdir /kosmtik && \
    cd /kosmtik && \
    wget --quiet -O - $ZIP_URL_BASE/$BRANCH_TAG.tar.gz | tar -xvz && \
    cd kosmtik-$BRANCH_TAG_IN_ZIP && \
    npm install && \
    chown -R node:node . && \
    usermod --login $HOST_USER node && \
    chmod 755 /run.sh

# Start the container
WORKDIR /kosmtik/kosmtik-$BRANCH_TAG_IN_ZIP
CMD /run.sh
