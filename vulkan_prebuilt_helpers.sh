#!/bin/bash
# helper functions for downloading/installing platform-specific Vulkan SDKs
# originally meant for use from GitHub Actions
#   see: https://github.com/humbletim/install-vulkan-sdk
# -- humbletim 2022.02

# example of running manually:
# $ . vulkan_prebuilt_helpers.
# $ VULKAN_SDK_VERSION=1.3.204.0 download_linux    # fetches vulkan_sdk.tar.xz
# $ VULKAN_SDK=$PWD/VULKAN_SDK install_linux       # installs

function _os_filename() {
  local os_type=$1
  if [[ "$os_type" == "linux-arm" ]]; then
    os_type="linux" # For filename lookup, assuming ARM uses linux SDKs for now. Adjust if needed.
  fi
  case $1 in
    mac) echo vulkan_sdk.dmg ;;
    linux|linux-arm) echo vulkan_sdk.tar.xz ;;
    windows) echo vulkan_sdk.exe ;;
    *) echo "unknown $1" >&2 ; exit 9 ;;
  esac
}

function download_vulkan_installer() {
  local os=$1
  local download_os=$os
  local filename=$(_os_filename $os)
  if [[ "$os" == "linux-arm" ]]; then
    download_os="linux" # Assuming ARM SDK is downloaded from Linux section. Adjust if needed.
  fi

  local url=https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/$download_os/$filename?Human=true
  echo "_download_os_installer $download_os $filename $url" >&2
  if [[ -f $filename ]] ; then
    echo "using cached: $filename" >&2
  else
    curl --fail-with-body -s -L -o ${filename}.tmp $url || { echo "curl failed with error code: $?" >&2 ; curl -s -L --head $url >&2 ; exit 32 ; }
    test -f ${filename}.tmp
    mv -v ${filename}.tmp ${filename}
  fi
  ls -lh $filename >&2
}

function unpack_vulkan_installer() {
  local os=$1
  local filename=$(_os_filename $os)
  test -f $filename
  install_os_${os}
}

function install_os_linux() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.tar.xz
  echo "extract just the SDK's prebuilt binaries ($VULKAN_SDK_VERSION/x86_64) from vulkan_sdk.tar.xz into $VULKAN_SDK" >&2
  tar -C "$VULKAN_SDK" --strip-components 2 -xJf vulkan_sdk.tar.xz $VULKAN_SDK_VERSION/x86_64 # Default x86_64 install
}

function install_os_linux-arm() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.tar.xz
  echo "extract just the SDK's prebuilt binaries (ARM64 - if available in SDK) from vulkan_sdk.tar.xz into $VULKAN_SDK" >&2
  if tar -tf vulkan_sdk.tar.xz | grep -q "$VULKAN_SDK_VERSION/arm64"; then
    echo "Found arm64 binaries in SDK, installing..." >&2
    tar -C "$VULKAN_SDK" --strip-components 2 -xJf vulkan_sdk.tar.xz $VULKAN_SDK_VERSION/arm64 # Try arm64 install if exists
  else
    install_os_linux # Fallback to x86_64 install if arm64 not found - might still be useful for headers/loader.
    echo "Warning: No arm64 binaries found in the downloaded Vulkan SDK. Installing x86_64 binaries instead. This might not work as expected on ARM." >&2
  fi
}

function install_os_windows() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.exe
  7z x vulkan_sdk.exe -aoa -o$VULKAN_SDK
}

function install_os_mac() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.dmg
  local mountpoint=$(hdiutil attach vulkan_sdk.dmg | grep -i vulkansdk | awk 'END {print $NF}')
  if [[ -d $mountpoint ]] ; then
    echo "mounted dmg image: 'vulkan_sdk.dmg' (mountpoint=$mountpoint)" >&2
  else
    echo "could not mount dmg image: vulkan_sdk.dmg (mountpoint=$mountpoint)" >&2
    exit 7
  fi
  local sdk_temp=$mountpoint
  # > Vulkan SDK 1.2.170.0 .dmgs have an installer
  if [[ -d $mountpoint/InstallVulkan.app ]] ; then
    sdk_temp=$VULKAN_SDK.tmp
    sudo $mountpoint/InstallVulkan.app/Contents/MacOS/InstallVulkan --root "$sdk_temp" --accept-licenses --default-answer --confirm-command install
  else
    true # <= 1.2.170.0 .dmgs are just packaged folders
  fi
  du -hs $sdk_temp
  test -d $sdk_temp/macOS || { echo "unrecognized dmg folder layout: $sdk_temp" ; ls -l $sdk_temp ; exit 10 ; }
  cp -r $sdk_temp/macOS/* $VULKAN_SDK/
  if [[ -d $mountpoint/InstallVulkan.app ]] ; then
    sudo rm -rf "$sdk_temp"
  fi
  hdiutil detach $mountpoint
}