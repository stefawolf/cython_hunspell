#!/bin/bash
# Build manylinux wheels for hunspell versions 1.7.0 through 1.7.3.
# The hunspell version appears as a build tag in the wheel filename, e.g.:
#   cyhunspell-2.0.6-172-cp310-cp310-manylinux_2_28_x86_64.whl
#                    ^^^
#                    hunspell 1.7.2 (dots removed)
#
# Usage:
#   ./build_all_hunspell_versions.sh              # Linux (default)
#   ./build_all_hunspell_versions.sh macos        # macOS
#   ./build_all_hunspell_versions.sh linux x86_64 # specific arch

set -euo pipefail

PLATFORM="${1:-linux}"
ARCHS="${2:-}"

HUNSPELL_VERSIONS="1.7.0 1.7.1 1.7.2 1.7.3"

for VERSION in $HUNSPELL_VERSIONS; do
    echo ""
    echo "========================================"
    echo "  Building with hunspell $VERSION"
    echo "========================================"

    ARCH_ARG=""
    if [ -n "$ARCHS" ]; then
        ARCH_ARG="--archs $ARCHS"
    fi

    # Pass HUNSPELL_VERSION explicitly into the cibuildwheel build environment.
    # CIBW_ENVIRONMENT_LINUX/MACOS overrides the pyproject.toml environment section,
    # so CC and CXX are repeated here for Linux.
    if [ "$PLATFORM" = "linux" ]; then
        export CIBW_ENVIRONMENT_LINUX="CC=/usr/bin/gcc CXX=/usr/bin/g++ HUNSPELL_VERSION=$VERSION"
    elif [ "$PLATFORM" = "macos" ]; then
        export CIBW_ENVIRONMENT_MACOS="HUNSPELL_VERSION=$VERSION"
    fi

    HUNSPELL_VERSION=$VERSION python -m cibuildwheel --platform "$PLATFORM" $ARCH_ARG
done

unset CIBW_ENVIRONMENT_LINUX CIBW_ENVIRONMENT_MACOS 2>/dev/null || true

echo ""
echo "All versions built. Wheels are in wheelhouse/:"
ls wheelhouse/*.whl 2>/dev/null | sort || echo "(none found)"
