#!/usr/bin/env bash

# Specify the "mode" for the server as the first parameter; e.g. "idp" or "broker"
docker run --rm -it \
    --mount "type=bind,source=$(pwd),destination=/usr/src/app" \
    -p 3000:3000 \
    vcspike "$@"
