# Typed Annotations for the Bindings SDK — Cross-Platform Design

> Status: **design + Phase 1 in progress** (branch `feat/HYB-951-flutter-bindings-phase2`).
> Goal: give bindings users **typed** annotations (and forms) instead of raw
> Instant-JSON strings, by **reusing** the existing legacy typed model hierarchy.

## Problem

The legacy `nutrient_flutter` package has a rich typed model hierarchy
(`lib/src/annotations/annotation_models.dart` — abstract `Annotation` + ~26
subclasses, and a parallel `PdfFormField` hierarchy in `lib/src/forms/`), each
with `fromJson`/`toJson` that map to/from **Instant JSON**. The legacy
`PdfDocument.getAnnotations()` already returns `List<Annotation>` as a thin
JSON-parsing wrapper.

The **bindings** API (`nutrient_flutter_platform_interface`) is raw JSON strings
end to end: `AnnotationManagerInterface.getAnnotationsJson() → String`,
`addAnnotation(String json)`, `FormManagerInterface.getFormFieldsJson() → String`,
and events (`AnnotationCreatedEvent(List<String> annotationsJson)`). The typed
models exist but are trapped in the legacy package and depend on the legacy
barrel + Flutter `material`.

## Deep-dive: is Instant JSON consistent across platforms?

Three platform deep-dives (Android jnigen + SDK, iOS ffigen + SDK, Web
js-interop + SDK) were run against the bindings serialization path. Headline:
**at the bindings read boundary (`getAnnotationsJson`), all three platforms
converge on spec Instant JSON** — hex colors (`#RRGGBB`), `bbox`/`rects` in PDF
coordinates (bottom-left origin), `pspdfkit/*` type strings. Android/iOS get this
natively (`toInstantJson()` / `generateInstantJSON()`); the Web binding
normalizes it (`{r,g,b}`→hex via `_convertColorsToHex`, injects the missing
`type` via `instanceof`).

### Consistency matrix (bindings path)

| Concern | Android | iOS | Web | Verdict |
|---|---|---|---|---|
| Read colors | hex (native) | hex (native) | hex (binding converts `{r,g,b}`) | consistent |
| `bbox` / coords | spec, PDF bottom-left | spec, PDF bottom-left | spec (getAnnotations) | consistent |
| Type strings | `pspdfkit/*` | `pspdfkit/*` | `pspdfkit/*` (injected) | mostly |
| Attachment binary | not inlined (bindings) | not inlined | never inlined | **consistent gap** — only `imageAttachmentId`, no bytes |
| Events | `toInstantJson` + `unknown` fallback | full Instant JSON | raw `JSON.stringify` — `{r,g,b}`, **no `type`**, `boundingBox` | **Web diverges** |
| `getUnsavedAnnotations` | works | works (FFI) | `[]` | Web gap |
| `searchAnnotations` | works | custom non-JSON (Pigeon) | `[]` | inconsistent |
| Type-filter arg | partial | broken (`type.name` sent) | falls through to "all" | pre-existing bug |
| Write (`addAnnotation`) | Instant JSON | FFI ok / Pigeon ad-hoc keys | `fromSerializableObject` | ok on bindings paths |

### Shared model bugs (in the Dart models — fix once, benefits all platforms)

1. **`measurementScale` / `measurementPrecision`**: `json[...] as MeasurementScale?`
   — silently `null` on Android/iOS, **runtime crash on Web** (it's a `dartify()`
   `Map`). Fix: `MeasurementScale.fromMap(...)`.
2. **Non-nullable casts that crash on a missing field**: `FreeTextAnnotation.font`
   (`as String`), `SoundAnnotation.soundUrl` (`as String`), `LinkAnnotation.action`
   (`as Map`). Fix: nullable + sensible defaults.
3. **Unknown types**: `pspdfkit/unknown` (Android/iOS detach fallback) and
   `pspdfkit/comment` (Web-only) hit `UnimplementedError`. Models only skip
   `pspdfkit/undefined`. Fix: parse defensively (skip / `UnknownAnnotation`).
4. **`RedactionAnnotation`** overwrites the native `bbox` with `rects.first`.
5. **Web-only**: flag `noPrint` unmapped (spec uses `noPrint`, model knows only
   `print`); `borderDashArray` vs spec `strokeDashArray`; alpha `#AARRGGBB` on
   write (Web wants `#RRGGBB`).

### Platform-specific behavior the typed layer must respect

- **Attachments (image/stamp/file binary)** are **not** transmitted by any
  bindings path — only `imageAttachmentId`. The typed layer treats `attachment`
  as `null` and exposes the id; binary bytes need a **dedicated
  `getAttachment(id)` API** (follow-up), not smuggling through the annotation
  JSON. Document so `toJson()`→`addAnnotation` doesn't silently drop images.
- **Events**: Android/iOS emit Instant JSON; **Web emits un-normalized payloads**
  (`{r,g,b}` colors, no `type`, `boundingBox` not `bbox`). Typed events need a
  **Web-adapter normalization step** before the shared parser.
- **`searchAnnotations` / `getUnsavedAnnotations`** are empty on Web (and
  iOS-Pigeon). Expose typed variants but document non-parity; optional follow-ups.
- **Type-filter arg** (`type.name` vs `type.fullName`) is a pre-existing bug —
  fix so typed `getAnnotations(type:)` actually filters.

## Plan

**Phase 1 — models.** Fix the 5 shared model bugs (in place, then they travel),
relocate the annotation + forms model hierarchy into
`nutrient_flutter_platform_interface` (it already depends on Flutter, so
`Color`/`BlendMode`/`BorderStyle` come along), decouple from the legacy barrel,
and **re-export** from `nutrient_flutter` so legacy code + tests keep working.
Reuse `annotation_type_test.dart`; add cases for each bug fix.

**Phase 2 — typed getters.** Add typed methods over the JSON interface
(`getAnnotations → List<Annotation>`, `addAnnotation(Annotation)`,
typed search / unsaved) as default implementations that wrap the existing
`*Json` methods — **no native changes**. Fix the type-filter arg.

**Phase 3 — typed events.** Add typed accessors on the events
(`AnnotationCreatedEvent.annotations`) + typed streams; the real work is **Web
adapter normalization** (Android/iOS events are already Instant JSON).

**Phase 4 — forms.** Same treatment for `PdfFormField`.

**Phase 5 — surface & verify.** Re-export from `bindings.dart`, add a catalog
example, cross-platform tests. Document the attachment-binary + search/unsaved
limitations.

### Design decisions

- **Model home:** `platform_interface` (Flutter dep already present).
- **Additive, not replacing:** keep `*Json` methods as the transport; add typed
  methods on top. Non-breaking, zero native changes. Deprecate JSON later.
- **Normalize in the model** for the read boundary (all platforms agree there);
  **normalize per-adapter** only for events (Web).
- **Color:** keep Flutter `Color` in the models; emit spec `#RRGGBB` (6-digit)
  unless alpha ≠ 0xFF. Note the mismatch with `AnnotationProperties` (`int` ARGB).

## Follow-ups (explicitly out of Phase 1–5 scope)

- `getAttachment(id)` API for image/stamp/file binary bytes.
- Implement `searchAnnotations` / `getUnsavedAnnotations` on Web.
- Fix iOS-Pigeon `searchAnnotationsJson` (custom map) + `addAnnotation` (ad-hoc
  keys) — or drop the Pigeon path once the bindings path is canonical.
