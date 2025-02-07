# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.
#
# Before building this image, be sure to have run the following commands in the repo root:
#
# yarn install --immutable
# yarn tsc
# yarn build:backend
#
# Once the commands have been run, you can build the image using `yarn build-image`

### BIG BANG STEPS ###
ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/nodejs/nodejs20
ARG BASE_TAG=20-slim

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
### BIG BANG STEPS ###

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Temporarily switch to root to install dependencies
USER root

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        python3 \
        g++ \
        make \
        automake \
        gcc \
        && \
    rm -rf /var/cache/apk
    # microdnf update -y --nodocs && \
    # microdnf -y install python3 gcc-c++ make automake gcc --nodocs && \
    # microdnf clean all && \
    # rm -rf /var/cache/dnf
    # kernel-devel 
    #
    # --mount=type=cache,target=/var/cache/apt,sharing=locked \
    # --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # apt-get update && \
    # apt-get install -y --no-install-recommends python3 g++ build-essential && \
    # rm -rf /var/lib/apt/lists/*

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        sqlite-dev \
        && \
    rm -rf /var/cache/apk
    # microdnf update -y --nodocs && \
    # microdnf -y install sqlite-devel --nodocs && \
    # microdnf clean all && \
    # rm -rf /var/cache/dnf
    #
    # --mount=type=cache,target=/var/cache/apt,sharing=locked \
    # --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # apt-get update && \
    # apt-get install -y --no-install-recommends libsqlite3-dev && \
    # rm -rf /var/lib/apt/lists/*

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

# Copy files needed by Yarn
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node backstage.json ./

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --chown=node:node yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# This will include the examples, if you don't need these simply remove this line
COPY --chown=node:node examples ./examples

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --chown=node:node packages/backend/dist/bundle.tar.gz app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Local command
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.docker.yaml"]
# Dev command
# CMD ["node", "packages/backend", "--config", "app-config.yaml"]
# Prod command (this is the one that should be uncommented when merging to main)
# CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
