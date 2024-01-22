FROM node:16-bullseye

ARG ZIP_URL_BASE
ARG BRANCH_TAG
ARG BRANCH_TAG_IN_ZIP
ARG HOST_USER
ARG HOT_UID
ARG HOST_GID

USER $HOST_UID:$HOST_GID

COPY run.sh register_fonts_from_hardcoded_directory.patch yaml_safeDump_config_js.patch yaml_safeDump_yaml_js.patch /

# It is required that the user running Kosmtik owns the files. I don't know why but it seems that
# it depends on that. Well it's NodeJS.
# In addition, it is required to change the symbolic name of the user called "node" by the base
# image to the name used by the user startig the container for PostgreSQL peer authentication to
# work.
RUN apt-get update && apt-get install -y wget libmapnik-dev libgdal-dev vim && \
    mkdir /kosmtik && \
    cd /kosmtik && \
    wget --quiet -O - $ZIP_URL_BASE/$BRANCH_TAG.tar.gz | tar -xvz && \
    cd /kosmtik/kosmtik-$BRANCH_TAG_IN_ZIP && \
    patch src/back/Project.js /register_fonts_from_hardcoded_directory.patch && \
    rm /register_fonts_from_hardcoded_directory.patch && \
    npm install && \
    node index.js plugins --install kosmtik-fetch-remote && \
    chown -R node:node . && \
    usermod --login $HOST_USER node && \
    chmod 755 /run.sh

# Start the container
WORKDIR /kosmtik/kosmtik-$BRANCH_TAG_IN_ZIP
CMD /run.sh
