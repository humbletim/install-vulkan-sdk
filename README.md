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
- *quiet* (optional; default=false): when using `latest` an Annotation is added to builds with actual SDK number; set `quiet: true` to silence.

### SDK Revisions

Several recent SDK releases (known to have installers available for all three windows/mac/linux platforms):
- 1.2.170.0
- 1.2.189.0
- 1.2.198.1
- 1.3.204.0

##### Tested SDK versions (as of 2022.02.26):
  - <sub><sup>[windows.json](https://vulkan.lunarg.com/sdk/versions/windows.json): 1.3.204.0 / 1.2.198.1 / 1.2.189.2 / 1.2.189.0 / 1.2.182.0 / 1.2.176.1 / 1.2.170.0 / 1.2.162.1 / 1.2.162.0 / 1.2.154.1 / 1.2.148.1 / 1.2.148.0</sup></sub>
  - <sub><sup>[linux.json](https://vulkan.lunarg.com/sdk/versions/linux.json): 1.3.204.0 / 1.2.198.1 / 1.2.189.0 / 1.2.182.0 / 1.2.176.1 / 1.2.170.0 / 1.2.162.1 / 1.2.162.0 / 1.2.148.1 / 1.2.148.0</sup></sub>
  - <sub><sup>[mac.json](https://vulkan.lunarg.com/sdk/versions/mac.json): 1.3.204.0 / 1.2.198.1 / 1.2.189.0 / 1.2.182.0 / 1.2.176.1 / 1.2.170.0 / 1.2.162.1 / 1.2.162.0 / 1.2.148.1 / 1.2.148.0</sup></sub>
</sup></sub>

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
