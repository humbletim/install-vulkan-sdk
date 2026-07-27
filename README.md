# install-vulkan-sdk v1.2

This action automatically downloads and installs the Vulkan SDK development environment.

### Usage

```yaml
  -name: Install Vulkan SDK
   uses: humbletim/install-vulkan-sdk@v1.2
   with:
     version: 1.4.309.0
     cache: true
```

Parameters:
- *version* (optional; default=latest): `N.N.N.N` style Vulkan SDK release number (or `latest` to use most recent official release).
- *cache* (optional; default=false): boolean indicating whether to cache the downloaded installer file between builds.
- *quiet* (optional; default=false): when using `latest` an Annotation is added to builds with actual SDK number; set `quiet: true` to silence.

### SDK Revisions

Know working SDK version for windows/mac/linux:
- 1.4.309.0

##### Available SDK versions:
  - [windows.json](https://vulkan.lunarg.com/sdk/versions/windows.json) / [warm.json](https://vulkan.lunarg.com/sdk/versions/warm.json)
  - [linux.json](https://vulkan.lunarg.com/sdk/versions/linux.json)
  - [mac.json](https://vulkan.lunarg.com/sdk/versions/mac.json) (version >= 1.3.296.0)
  - see also https://vulkan.lunarg.com/sdk/home

### Environment

Exported variables:
- `VULKAN_SDK` (standard variable used by cmake and other build tools)
- `VULKAN_SDK_VERSION`
- `VULKAN_SDK_PLATFORM`
- `PATH` is extended to include `VULKAN_SDK/bin` (so SDK tools like `glslangValidator` can be used directly)

### Caveats

Please be aware that Vulkan SDKs can use a lot of disk space; windows/linux approximately ~0.75GB; macos approximately ~1.75GB (mostly `lib/libshaderc_combined.a`).

If your project only depends on Vulkan-Headers and Vulkan-Loader to compile and link against then you may want to consider using [humbletim/setup-vulkan-sdk](https://github.com/humbletim/setup-vulkan-sdk) instead, which allows building individual SDK components directly from Khronos source repos (and uses less disk space).

## References
- [Vulkan SDK](https://www.lunarg.com/vulkan-sdk/)
- [Vulkan SDK web services API](https://vulkan.lunarg.com/content/view/latest-sdk-version-api)
- [humbletim/setup-vulkan-sdk](https://github.com/humbletim/setup-vulkan-sdk)
