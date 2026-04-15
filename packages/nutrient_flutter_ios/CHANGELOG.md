# Next version

- Adds `NutrientInstantViewIOS`, an iOS implementation of the embedded Instant document widget using `PSPDFInstantViewController` via FFI. (J#HYB-988)
- Fixes Instant two-way sync by retaining the `PSPDFInstantDocumentDescriptor` for the lifetime of the view controller, preventing ARC from releasing it and discarding the sync configuration. (J#HYB-988)
- Adds `IOSConfigurationBuilder` to convert `NutrientViewConfiguration` into a `PSPDFConfigurationBuilder` JSON dict, supporting all major viewer options. (J#HYB-988)

## 1.0.2 - 24 Feb 2026

- Fixes a build error where `NutrientIOSBindings.m` failed to compile with `'PSPDFKit/PSPDFKit.h' file not found` when using the plugin from a third-party app. The native-assets hook now resolves the PSPDFKit Pods directory from the consuming app instead of the plugin's own example app. (#50888)
- Fixes `getViewController` thread safety by dispatching to the main thread when called from a background thread. (#50888)
- Improves build error reporting in `hook/build.dart` by replacing a silent `assert` with an explicit exception. (#50888)

## 1.0.1 - 22 Feb 2026

- Updates to Nutrient iOS SDK 26.5.0. (#50888)
- Regenerates FFI bindings for Nutrient iOS SDK 26.5.0. (#50888)
- Adds a native-assets build hook (`hook/build.dart`) to compile ObjC protocol trampolines into a bundled dylib, fixing the `No asset found` runtime error for FFI delegates. (#50888)
- Fixes an issue where `nutrient_get_view_controller` returned null when called from the `AdapterBridge` / `NutrientView` path. (#50888)
- Fixes AOT compilation errors caused by system opaque-struct globals (`_xpc_*`, `_dispatch_*`, `kDNSService*`) in the generated bindings. (#50888)
- Updates `objective_c` to 9.3.0, `ffi` to 2.2.0, `ffigen` to 20.1.1, `code_assets` to 1.0.0, `hooks` to 1.0.0, `native_toolchain_c` to 0.17.4. (#50888)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Native iOS bindings using FFI for direct Nutrient iOS SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
