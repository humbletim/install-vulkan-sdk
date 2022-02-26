# install-vulkan-sdk v1.1.1

[![test install-vulkan-sdk](https://github.com/humbletim/install-vulkan-sdk/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/humbletim/install-vulkan-sdk/actions/workflows/ci.yml)

This action automatically downloads and installs the Vulkan SDK development environment.

### Usage

```yaml
  -name: Install Vulkan SDK
   uses: humbletim/install-vulkan-sdk@v1.1.1
   with:
     version: 1.3.204.0
     cache: true
```

Parameters:
- *version* (required): `N.N.N.N` style Vulkan SDK release number (or `latest` to use most recent official release).
- *cache* (optional; default=false): boolean indicating whether to cache the downloaded installer file between builds.

### SDK Revisions

Several recent SDK releases (known to have installers available for all three windows/mac/linux platforms):
- 1.2.170.0
- 1.2.189.0
- 1.2.198.1
- 1.3.204.0

Additional release numbers can be found at https://vulkan.lunarg.com/sdk/home.

### Environment

Exported variables:
- `VULKAN_SDK` (standard variable used by cmake and other build tools)
- `VULKAN_SDK_VERSION`
- `VULKAN_SDK_PLATFORM`
- `PATH` is extended to include `VULKAN_SDK/bin` (so SDK tools like `glslangValidator` can be used directly)

### Caveats

Please be aware that Vulkan SDKs can use a lot of disk space -- recently reported 1.3.204.0 installation sizes:
  - windows: 617M
  - linux: 631M
  - mac: 1.8G (1.3G of that being `lib/libshaderc_combined.a`)

If your project only depends on Vulkan-Headers and Vulkan-Loader to compile and link against then you may want to consider using [humbletim/setup-vulkan-sdk](https://github.com/humbletim/setup-vulkan-sdk) instead, which allows building individual SDK components directly from Khronos source repos (and uses less disk space).

## References
- [Vulkan SDK](https://www.lunarg.com/vulkan-sdk/)
- [Vulkan SDK web services API](https://vulkan.lunarg.com/content/view/latest-sdk-version-api)
- [humbletim/setup-vulkan-sdk](https://github.com/humbletim/setup-vulkan-sdk)
