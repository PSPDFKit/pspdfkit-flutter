# Nutrient Flutter Bindings Migration Guide

## Overview

The Nutrient Flutter SDK now ships a second public surface — the **bindings
API** — alongside the legacy method-channel API. The bindings API drives
each platform's native SDK directly (JNI on Android, FFI on iOS, JS interop
on Web) instead of routing every call through a `MethodChannel`/`Pigeon`,
which gives apps:

- A typed `controller.events` stream over the same `Stream<NutrientEvent>`
  shape on every platform.
- A cleaner extension model — `NutrientPlatformAdapter` subclasses replace
  ad-hoc `addEventListener` registrations and `MethodChannel`-fronted
  configuration maps.
- Direct access to native SDK objects (`PdfFragment`, `PSPDFViewController`,
  `nutrient_web.Instance`) when you need to reach further than the public
  Flutter API.

The legacy method-channel API (`Nutrient.present()`, `PdfDocument`,
`NutrientView`, `PdfConfiguration`, …) is unchanged and still supported.
You can migrate one screen at a time, or pick the bindings API for new
work while keeping existing screens on the legacy API.

This guide covers the changes that landed alongside the bindings API and
how to migrate an app that's already using the bindings (or that mixes the
two surfaces). If you're still on the pre-bindings legacy API, no migration
is required — your app keeps working as-is.

## Quick reference

```dart
// Legacy method-channel API (unchanged)
import 'package:nutrient_flutter/nutrient_flutter.dart';
await Nutrient.present('document.pdf');

// Bindings-based API (new)
import 'package:nutrient_flutter/bindings.dart';
await Nutrient.initialize(
  androidAdapter: MyAndroidAdapter(),
  iosAdapter: MyIOSAdapter(),
  webAdapter: MyWebAdapter(),
);
NutrientDocumentView(
  documentPath: 'document.pdf',
  onControllerReady: (controller) async {
    controller.events.pageChanged.listen((e) => print('Page ${e.pageIndex}'));
    final pageCount = await controller.document.getPageCount();
  },
);
```

## Changes

### 1. New `package:nutrient_flutter/bindings.dart` sub-library

`package:nutrient_flutter/bindings.dart` is the single import for the
bindings API. It re-exports everything from
`nutrient_flutter_platform_interface` plus `NutrientDocumentView`. New apps
targeting the bindings surface should import this library rather than
mixing imports from `nutrient_flutter`, `nutrient_flutter_platform_interface`,
and the per-platform packages.

**Before** — three imports plus a `hide` clause to resolve collisions with
the legacy pigeon-generated types:

```dart
import 'package:nutrient_flutter/nutrient_flutter.dart'
    hide
        Nutrient, Bookmark, PageInfo, AnnotationProperties,
        DocumentSaveOptions, AnnotationTool, NutrientEvent;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
```

**After** — one import:

```dart
import 'package:nutrient_flutter/bindings.dart';
```

If your app still uses the legacy method-channel surface anywhere, keep
`import 'package:nutrient_flutter/nutrient_flutter.dart';` for those files
(or alias the two libraries) — the libraries are independent.

### 2. Direct dependencies on the federated packages

For now, apps that use the bindings still need to list each federated
package as a direct dependency in `pubspec.yaml` so the native plugins
are registered at runtime (this matches the shape the legacy example
app has used since 5.5.0):

```yaml
dependencies:
  nutrient_flutter: ^5.6.0
  nutrient_flutter_platform_interface: ^1.1.0
  nutrient_flutter_android: ^1.1.0
  nutrient_flutter_ios: ^1.1.0
  nutrient_flutter_web: ^1.1.0
```

We tried collapsing this to a single direct dep via Flutter plugin
federation `default_package` entries, but the resulting registration
flow drops `nutrient_flutter`'s own Android / iOS plugins — which also
host the legacy method-channel and Pigeon handlers used by every
existing `Nutrient.present(...)` / `PdfDocument.*` call site. The
trade-off wasn't worth it for this release. See
[`bindings-federation-cleanup.md`](bindings-federation-cleanup.md) for
the plan to collapse this to a single direct dep once the legacy
method-channel surface is removed.

### 3. `FlutterAppCompatActivity` now ships in `nutrient_flutter_android`

The `io.flutter.embedding.android.FlutterAppCompatActivity` workaround
class — a Nutrient-maintained mirror of the upstream
`io.flutter.embedding.android.FlutterFragmentActivity` that extends
`androidx.appcompat.app.AppCompatActivity` instead of `FragmentActivity` —
now ships in `nutrient_flutter_android`'s Android module. The legacy
`nutrient_flutter` module still carries its own copy of the class (its
plugin code references it directly), so both modules define it. They don't
collide because `implements: nutrient_flutter` makes Flutter link only the
federated module's native code when both packages are present — which is
exactly why that declaration must stay until the legacy Android module is
retired. See
[bindings-federation-cleanup.md](bindings-federation-cleanup.md).

The class is also re-synced with upstream at
[flutter/flutter@0541913d8][upstream]. The Nutrient-specific deltas are
now limited to:

- The base class swap (`extends FragmentActivity` →
  `extends AppCompatActivity`).
- The class rename (`FlutterFragmentActivity` → `FlutterAppCompatActivity`).

The previous `implements AiAssistantProvider` integration that delegated
to `PSPDFKitView.Companion.getAiAssistant()` has been removed because that
delegation required reaching into the legacy `nutrient_flutter` Android
module, which the bindings package cannot depend on.

**Migration scenarios:**

#### a) You only used `FlutterAppCompatActivity` as your activity (no AI Assistant integration)

No change needed if your `pubspec.yaml` already lists
`nutrient_flutter_android` as a direct dep (as the legacy example does).
The class still ships on
Android when you depend on `nutrient_flutter`. Your existing
`AndroidManifest.xml` reference to
`io.flutter.embedding.android.FlutterAppCompatActivity` keeps working.

#### b) You depended on the embedded `AiAssistantProvider` integration

Re-add the integration in your own app module by subclassing
`FlutterAppCompatActivity`:

```java
// android/app/src/main/java/com/example/myapp/MyFlutterActivity.java
package com.example.myapp;

import android.graphics.RectF;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterAppCompatActivity;
import io.nutrient.domain.ai.AiAssistant;
import io.nutrient.domain.ai.AiAssistantProvider;
import com.pspdfkit.flutter.pspdfkit.PSPDFKitView;

import java.util.List;

public class MyFlutterActivity extends FlutterAppCompatActivity
    implements AiAssistantProvider {

  @Nullable
  @Override
  public AiAssistant getAiAssistant() {
    return PSPDFKitView.Companion.getAiAssistant();
  }

  @Override
  public void navigateTo(@NonNull List<? extends RectF> list, int i, int i1) {
    // No-op — matches the previous default implementation.
  }
}
```

Then point your `AndroidManifest.xml` at `com.example.myapp.MyFlutterActivity`
instead of `io.flutter.embedding.android.FlutterAppCompatActivity`:

```xml
<activity
    android:name="com.example.myapp.MyFlutterActivity"
    android:exported="true"
    ...>
</activity>
```

The `PSPDFKitView` reference requires that your app still depends on the
legacy `nutrient_flutter` plugin (which provides the `PSPDFKitView` Kotlin
class). That's already the case by default — `nutrient_flutter` is the
wrapper you depend on.

#### c) You explicitly listed `nutrient_flutter_android` / `_ios` / `_web` as direct deps in your `pubspec.yaml`

Keep them. This is currently the required shape for bindings users (the
listings ensure the federated plugins are registered at runtime).
Collapsing to a single direct dep is tracked as a follow-up in
[`bindings-federation-cleanup.md`](bindings-federation-cleanup.md).

### 4. `AnnotationProperties` color fields are `int?`

Independent of the bindings work, `AnnotationProperties.strokeColor` and
`AnnotationProperties.fillColor` changed from `String?` (hex,
`"#FF0000"`) to `int?` (ARGB, `0xFFFF0000`). This aligns the type with how
`withColor`, `withFillColor`, and the `color` / `fillColorValue` getters
already worked.

```dart
// Before
final props = AnnotationProperties(strokeColor: '#FF0000');

// After
final props = AnnotationProperties(strokeColor: 0xFFFF0000);
// or
final props = AnnotationProperties(strokeColor: Colors.red.toARGB32());
```

[upstream]: https://github.com/flutter/flutter/blob/0541913d86dbfeec41c5ab3ad93a5fc64d1236be/engine/src/flutter/shell/platform/android/io/flutter/embedding/android/FlutterFragmentActivity.java
