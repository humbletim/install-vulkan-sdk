# helper functions for downloading/installing platform-specific Vulkan SDKs
# originally meant for use from GitHub Actions
#   see: https://github.com/humbletim/install-vulkan-sdk
# -- humbletim 2022.02

# example of running manually:
# $ . vulkan_prebuilt_helpers.
# $ VULKAN_SDK_VERSION=1.3.204.0 download_linux    # fetches vulkan_sdk.tar.gz
# $ VULKAN_SDK=$PWD/VULKAN_SDK install_linux       # installs

function _os_filename() {
  case $1 in
    mac) echo vulkan_sdk.dmg ;;
    linux) echo vulkan_sdk.tar.gz ;;
    windows) echo vulkan_sdk.exe ;;
    *) echo "unknown $1" >&2 ; exit 9 ;;
  esac
}

function download_vulkan_installer() {
  local os=$1
  local filename=$(_os_filename $os)
  local url=https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/$os/$filename?Human=true
  echo "_download_os_installer $os $filename $url" >&2
  if [[ -f $filename ]] ; then
    echo "using cached: $filename"
  else
    curl -s -L -o $filename $url
    test -f $filename
  fi
  ls -lh $filename >&2
}

function unpack_vulkan_installer() {
  local os=$1
  local filename=$(_os_filename $os)
  test -f $filename
  install_${os}
}

function install_linux() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.tar.gz
  echo "extract just the SDK's prebuilt binaries ($VULKAN_SDK_VERSION/x86_64) from vulkan_sdk.tar.gz into $VULKAN_SDK" >&2
  tar -C "$VULKAN_SDK" --strip-components 2 -xf vulkan_sdk.tar.gz $VULKAN_SDK_VERSION/x86_64
}

function install_windows() {
  test -d $VULKAN_SDK && test -f vulkan_sdk.exe
  7z x vulkan_sdk.exe -aoa -o$VULKAN_SDK
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
  local sdk_temp=$mountpoint
  # > Vulkan SDK 1.2.170.0 .dmgs have an installer
  if [[ test -d $mountpoint/InstallVulkan.app ]] ; then
    sdk_temp=$VULKAN_SDK.tmp
    sudo $mountpoint/InstallVulkan.app/Contents/MacOS/InstallVulkan --root "$sdk_temp" --accept-licenses --default-answer --confirm-command install
  else
    # <= 1.2.170.0 .dmgs are just packaged folders
  fi
  du -hs $sdk_temp
  cp -r $sdk_temp/macOS/* $VULKAN_SDK/
  if [[ test -d $mountpoint/InstallVulkan.app ]] ; then
    sudo rm -rf "$sdk_temp"
  fi
  hdiutil detach $mountpoint
}
