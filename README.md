# docker-compose binaries for aarch64

This repository contains helpers to build a docker-compose binary for aarch64/arm64. This project exists because, currently, docker-compose [releases](https://github.com/docker/compose/releases) do not include an aarch64 binary.

## To build

You may wish to edit the docker-compose version inside the Dockerfile. Then:

```bash
docker build . -t docker-compose-aarch64-builder
docker run --rm -v "$(pwd)":/dist docker-compose-aarch64-builder
# this will generate a `docker-compose-Linux-aarch64` in "$(pwd)"
```

