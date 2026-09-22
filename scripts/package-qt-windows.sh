#!/usr/bin/env bash
# Reproducible Windows packaging for the Qt app.
#
# Produces the two release artifacts:
#   * a portable ZIP that runs from an unpacked folder with no install step
#   * an MSI installer
#
# Both carry a file named "@Release" at the payload root; the marker is written
# by opennow-qt/cmake/ReleaseMarker.cmake and asserted by
# opennow-qt/packaging/windows-release.ps1.
#
# Usage:
#   scripts/package-qt-windows.sh                # build, then ZIP + MSI
#   scripts/package-qt-windows.sh -G ZIP         # portable ZIP only
#   scripts/package-qt-windows.sh --fetch-wix    # provision WiX v3 under build/
#   scripts/package-qt-windows.sh --no-build     # package an existing build
#
# Environment:
#   OPENNOW_BUILD_DIR      build directory   (default build/opennow-qt-release)
#   OPENNOW_PACKAGES_DIR   output directory  (default build/qt-packages)
#   OPENNOW_BUILD_JOBS     parallel builds   (default: CPU count)

set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
build_dir=${OPENNOW_BUILD_DIR:-build/opennow-qt-release}
packages_dir=${OPENNOW_PACKAGES_DIR:-build/qt-packages}
generators="WIX;ZIP"
wix_dir="$root/build/wix314"
wix_url="https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314-binaries.zip"
fetch_wix=0
skip_build=0

usage() { sed -n '2,25p' "${BASH_SOURCE[0]}"; }

while [ $# -gt 0 ]; do
    case "$1" in
        -G|--generators) generators="$2"; shift 2 ;;
        -B|--build-dir) build_dir="$2"; shift 2 ;;
        --fetch-wix) fetch_wix=1; shift ;;
        --no-build) skip_build=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

for tool in cmake cpack; do
    command -v "$tool" >/dev/null 2>&1 || { echo "$tool is not on PATH" >&2; exit 1; }
done

cd "$root"

extract_zip() {
    local archive="$1" destination="$2"
    if command -v unzip >/dev/null 2>&1; then
        unzip -q -o "$archive" -d "$destination"
    else
        powershell -NoProfile -Command "Expand-Archive -LiteralPath '$archive' -DestinationPath '$destination' -Force"
    fi
}

# WiX v3 drives the MSI generator. Its binaries ship as a plain ZIP, so they can
# live inside the project without an administrator install.
ensure_wix() {
    if command -v candle >/dev/null 2>&1 && command -v light >/dev/null 2>&1; then
        return 0
    fi
    if [ -x "$wix_dir/candle.exe" ] || [ -x "$wix_dir/candle" ]; then
        export PATH="$wix_dir:$PATH"
        return 0
    fi
    if [ "$fetch_wix" -eq 1 ]; then
        echo "Fetching WiX v3 into build/wix314"
        mkdir -p "$wix_dir"
        curl -fsSL -o "$wix_dir/wix314-binaries.zip" "$wix_url"
        extract_zip "$wix_dir/wix314-binaries.zip" "$wix_dir"
        rm -f "$wix_dir/wix314-binaries.zip"
        export PATH="$wix_dir:$PATH"
        if ! command -v candle >/dev/null 2>&1 && ! command -v candle.exe >/dev/null 2>&1; then
            echo "The WiX archive did not provide candle" >&2
            exit 1
        fi
        return 0
    fi
    cat >&2 <<'EOF'
The MSI generator needs WiX v3, and candle/light are not on PATH.

Provision it inside the project (no administrator rights needed):

  scripts/package-qt-windows.sh --fetch-wix

Or produce only the portable artifact:

  scripts/package-qt-windows.sh -G ZIP
EOF
    exit 1
}

if [[ "$generators" == *WIX* ]]; then
    ensure_wix
fi

if [ "$skip_build" -eq 0 ]; then
    if [ ! -f "$build_dir/CMakeCache.txt" ]; then
        cmake -S opennow-qt -B "$build_dir" -DCMAKE_BUILD_TYPE=Release
    fi
    configured_type=$(sed -n 's/^CMAKE_BUILD_TYPE:STRING=//p' "$build_dir/CMakeCache.txt")
    if [ -n "$configured_type" ] && [ "$configured_type" != "Release" ]; then
        echo "warning: $build_dir is configured as $configured_type, not Release" >&2
    fi
    jobs=${OPENNOW_BUILD_JOBS:-}
    if [ -z "$jobs" ]; then
        jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 8)
    fi
    cmake --build "$build_dir" --config Release --parallel "$jobs"
fi

if [ ! -f "$build_dir/CPackConfig.cmake" ]; then
    echo "$build_dir/CPackConfig.cmake is missing; configure the build first" >&2
    exit 1
fi

mkdir -p "$packages_dir"
cpack --config "$build_dir/CPackConfig.cmake" -C Release -G "$generators" -B "$packages_dir"

# Fail loudly if an artifact is missing the release marker.
for archive in "$packages_dir"/*.zip; do
    [ -e "$archive" ] || continue
    if command -v unzip >/dev/null 2>&1; then
        unzip -l "$archive" | grep -q '@Release' || {
            echo "$archive does not contain @Release" >&2
            exit 1
        }
    fi
done

echo
echo "Artifacts in $packages_dir:"
ls -l "$packages_dir"
