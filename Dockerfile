# Dockerfile to build docker-compose for aarch64 (check hub.docker.com/r/arm64v8/python)
FROM arm64v8/python:3.7.5-stretch

# Add env
ENV LANG C.UTF-8

# Enable cross-build for aarch64
COPY ./vendor/qemu-bin /usr/bin/
RUN [ "cross-build-start" ]

# Set the versions
ENV DOCKER_COMPOSE_VER 1.25.0
# docker-compose requires pyinstaller  (check github.com/docker/compose/blob/master/requirements-build.txt)
# If this changes, you may need to modify the version of "six" below
ENV PYINSTALLER_VER 3.5
# "six" is needed for PyInstaller. (check github.com/docker/compose/blob/master/requirements.txt)
ENV SIX_VER 1.12.0

# Install dependencies
# RUN apt-get update && apt-get install -y
RUN pip install --upgrade pip
RUN pip install six==$SIX_VER

# Compile the pyinstaller "bootloader"
# https://pyinstaller.readthedocs.io/en/stable/bootloader-building.html
WORKDIR /build/pyinstallerbootloader
RUN curl -fsSL https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VER/PyInstaller-$PYINSTALLER_VER.tar.gz | tar xvz >/dev/null \
    && cd PyInstaller*/bootloader \
    && python3 ./waf all

# Clone docker-compose
WORKDIR /build/dockercompose
RUN git clone https://github.com/docker/compose.git . \
    && git checkout $DOCKER_COMPOSE_VER

# Run the build steps (taken from github.com/docker/compose/blob/master/script/build/linux-entrypoint)
RUN mkdir ./dist \
    && pip install -r requirements.txt -r requirements-build.txt \
    && ./script/build/write-git-sha > compose/GITSHA \
    && pyinstaller --exclude-module pycrypto --exclude-module PyInstaller docker-compose.spec \
    && mv dist/docker-compose ./docker-compose-$(uname -s)-$(uname -m)

# Disable cross-build for aarch64
# Note: don't disable this, since we want to run this container on x86_64, not aarch64
# RUN [ "cross-build-end" ]

# Copy out the generated binary
VOLUME /dist
CMD cp docker-compose-* /dist
