#!/bin/bash
# Script to generate a qemu binary for an arm64 target
set -euo pipefail

# Set the target platform
#TARGET="arm"
TARGET="arm64"

# Get the destination
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST="$SCRIPT_DIR/qemu-bin/"

# Empty out the destination
rm -r "$DEST" || true

# Clone the resin patcher
cd "$(mktemp -d)"
git clone --depth 1 https://github.com/resin-io-projects/armv7hf-debian-qemu.git
cd armv7hf-debian-qemu

# Clean out the stuff we're about to build, then copy over the rest
rm bin/qemu-arm-static
md5 bin/resin-xbuild
rm bin/resin-xbuild
cp -a bin/ "$DEST"

# Build the binary and copy it over
# TBH, I don't know why we need to rebuild this binary... After a lot of experimentation,
# I found out that the binary shipped with the git repo (as of Apr 11 2018, Latest commit d4a214f on Jul 2, 2017)
# doesn't work in an aarch64 host. ?????
GOOS=linux GOARCH=amd64 ./build.sh
cp resin-xbuild "$DEST"

# Get qemu
case "$TARGET" in
    "arm64")
        curl -L https://github.com/resin-io/qemu/releases/download/v2.9.0%2Bresin1/qemu-2.9.0.resin1-aarch64.tar.gz | tar xzf -
        ;;
    "arm")
        curl -L https://github.com/resin-io/qemu/releases/download/v2.9.0%2Bresin1/qemu-2.9.0.resin1-arm.tar.gz | tar xzf -
        ;;
    *)
        echo "Unknown target $TARGET"
        exit 1
        ;;
esac

# Copy qemu
cp qemu*/* "$DEST"

echo -e "\n\n"
echo "================================"
echo "Successfully built for $TARGET!"
echo "================================"
