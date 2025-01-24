# Build Vars Spoofing

Build Vars Spoofing. **Android 8.1 or above is required**.

## Usage

1. Flash this module and reboot.
2. Enjoy!

You can try enabling/disabling Build variable spoofing by creating/deleting the file `/data/adb/build_var_spoof/spoof_build_vars`.

Build Vars Spoofing will automatically generate example config props inside `/data/adb/build_var_spoof/spoof_build_vars` once created, on next reboot, then you may manually edit your spoof config.

Here is an example of a spoof config:

```
MANUFACTURER=Google
MODEL=Pixel 6 Pro
FINGERPRINT=google/raven_beta/raven:15/BP11.241210.004/12926906:user/release-keys
BRAND=google
PRODUCT=raven_beta
DEVICE=raven
RELEASE=15
ID=BP11.241210.004
INCREMENTAL=12926906
TYPE=user
TAGS=release-keys
SECURITY_PATCH=2025-01-05
DEVICE_INITIAL_SDK_INT=35
```

## Acknowledgement

- [PlayIntegrityFix](https://github.com/chiteroman/PlayIntegrityFix)
- [LSPosed](https://github.com/LSPosed/LSPosed)
