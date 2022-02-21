# helper functions for downloading/installing platform-specific Vulkan SDKs
# originally meant for use from GitHub Actions
#   see: https://github.com/humbletim/install-vulkan-sdk
# -- humbletim 2022.02

# example of running manually:
# $ . vulkan_prebuilt_helpers.
# $ VULKAN_SDK_VERSION=1.3.204.0 download_linux    # fetches vulkan_sdk.tar.gz
# $ VULKAN_SDK=$PWD/VULKAN_SDK install_linux       # installs

function download_linux() {
  local url=https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/linux/vulkan_sdk.tar.gz?Human=true
  test -f vulkan_sdk.tar.gz || curl -s -L -o vulkan_sdk.tar.gz https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/linux/vulkan_sdk.tar.gz?Human=true
  echo url=$url ; ls -l vulkan_sdk.tar.gz ; test -f vulkan_sdk.tar.gz
}

function install_linux() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.tar.gz
  echo "extract just the SDK's prebuilt binaries ($VULKAN_SDK_VERSION/x86_64) from vulkan_sdk.tar.gz into $VULKAN_SDK" >&2
  tar -C "$VULKAN_SDK" --strip-components 2 -xf vulkan_sdk.tar.gz $VULKAN_SDK_VERSION/x86_64
}

function download_windows() {
  test -f vulkan_sdk.exe || curl -s -L -o vulkan_sdk.exe https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/windows/vulkan_sdk.exe?Human=true
  test -f vulkan_sdk.exe
}

function install_windows() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.exe
  7z x vulkan_sdk.exe -aoa -o$VULKAN_SDK
}

function download_mac() {
  test -f vulkan_sdk.dmg || curl -s -L -o vulkan_sdk.dmg https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/mac/vulkan_sdk.dmg?Human=true
  test -f vulkan_sdk.dmg
}

function install_mac() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.dmg
  local mountpoint=$(hdiutil attach vulkan_sdk.dmg | grep vulkansdk | awk 'END {print $NF}')
  if [[ -d $mountpoint ]] ; then
    echo "mounted dmg image: 'vulkan_sdk.dmg' (mountpoint=$mountpoint)" >&2
  else
    echo "could not mount dmg image: vulkan_sdk.exe (mountpoint=$mountpoint)" >&2
    exit 7
  fi
  local sdk_temp=$VULKAN_SDK.tmp
  sudo $mountpoint/InstallVulkan.app/Contents/MacOS/InstallVulkan --root "$sdk_temp" --accept-licenses --default-answer --confirm-command install
  du -hs $sdk_temp
  cp -r $sdk_temp/macOS/* $VULKAN_SDK/
  hdiutil detach $mountpoint
  sudo rm -rf "$sdk_temp"
}
