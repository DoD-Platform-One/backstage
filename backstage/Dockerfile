# Adapted from https://backstage.io/docs/deployment/docker/#multi-stage-build
# Stage 1 - Create yarn install skeleton layer
### BIG BANG STEPS ###
ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/nodejs/nodejs20
ARG BASE_TAG=20-slim-amd64

# Note there are more BIG BANG STEPS in the next stages
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} AS packages
### BIG BANG STEPS ###

WORKDIR /app
COPY backstage.json package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

COPY packages packages

# Comment this out if you don't have any internal plugins
# COPY plugins plugins

# permissions to rm
USER root

RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+

# switch back to node
USER node

# Stage 2 - Install dependencies and build packages
### BIG BANG STEPS ###
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} AS build
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

USER node
WORKDIR /app

COPY --from=packages --chown=node:node /app .
COPY --from=packages --chown=node:node /app/.yarn ./.yarn
COPY --from=packages --chown=node:node /app/.yarnrc.yml  ./
COPY --from=packages --chown=node:node /app/backstage.json ./

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --immutable

COPY --chown=node:node . .

RUN yarn tsc
RUN yarn --cwd packages/backend build

RUN mkdir packages/backend/dist/skeleton packages/backend/dist/bundle \
    && tar xzf packages/backend/dist/skeleton.tar.gz -C packages/backend/dist/skeleton \
    && tar xzf packages/backend/dist/bundle.tar.gz -C packages/backend/dist/bundle

# Stage 3 - Build the actual backend image and install production dependencies
### BIG BANG STEPS ###
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
# If it is instead created as `root` then the `tar` command below will
# fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`)
# so the app dir is correctly created as `node`.
WORKDIR /app

# Copy the install dependencies from the build stage and context
COPY --from=build --chown=node:node /app/.yarn ./.yarn
COPY --from=build --chown=node:node /app/.yarnrc.yml  ./
COPY --from=build --chown=node:node /app/backstage.json ./
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton/ ./

# Note: The skeleton bundle only includes package.json files -- if your app has
# plugins that define a `bin` export, the bin files need to be copied as well to
# be linked in node_modules/.bin during yarn install.

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# Copy the built packages from the build stage
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle/ ./

# Copy any other files that we need at runtime
COPY --chown=node:node app-config*.yaml ./

# This will include the examples, if you don't need these simply remove this line
COPY --chown=node:node examples ./examples

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Local command
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.docker.yaml"]
# Dev command
# CMD ["node", "packages/backend", "--config", "app-config.yaml"]
# Prod command (this is the one that should be uncommented when merging to main)
# CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
