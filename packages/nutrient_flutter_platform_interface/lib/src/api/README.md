# `src/api/` — Pigeon-generated transport types

This directory holds the **Pigeon-generated** Dart bindings
(`nutrient_api.g.dart`). It is the *single* source of the IPC types that
flow between Dart and the native plugins. Both the legacy
`nutrient_flutter` plugin and the federated `nutrient_flutter_android`
/ `_ios` / `_web` packages reach in here for their transport code.

## Don't expose these types in public APIs

Pigeon explicitly warns against exposing the generated classes as
public API surface. Reasons:

- The generated codec and class shapes can change across Pigeon
  releases without notice — anything that depends on them externally
  becomes a hidden breaking-change risk.
- Several Pigeon classes here share names with hand-written, *public*
  types defined under `nutrient_flutter_platform_interface/lib/src/models/`
  (`PageInfo`, `Bookmark`, `DocumentSaveOptions`,
  `AnnotationProperties`, …). The hand-written ones are the API; the
  generated ones are transport. Don't mix them at API boundaries.

The file lives under `lib/src/` precisely so that consumers must use a
deep import (`package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart`)
to reach it — that's a deliberate friction signal. The
`nutrient_flutter_platform_interface` public barrel
(`nutrient_flutter_platform_interface.dart`) does *not* export this
file.

## Where to map at the IPC boundary

When the native side returns a Pigeon class (say `Pigeon.PageInfo`)
and you need to surface the public `PageInfo` (from
`src/models/page_info.dart`), do the conversion in the native-facing
code (`document/pdf_document_native.dart`,
`document/headless_pdf_document_native.dart`, etc.). The conversion
sites are the documented IPC boundary; everything above them speaks
only hand-written types.

## Regenerating

```bash
cd flutter/nutrient_flutter
dart run pigeon --input pigeons/nutrient.dart
```

Pigeon owns this file end-to-end — don't hand-edit. Edit
`pigeons/nutrient.dart` in `nutrient_flutter` and re-run codegen.
