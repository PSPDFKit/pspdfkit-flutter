# Configuring Signatures

Control the electronic-signature creation UI — its input modes, ink colors,
fonts, and layout — and whether signatures are saved for reuse, all from your
`NutrientViewConfiguration`.

Two fields on [`NutrientViewConfiguration`](view-configuration-guide.md) drive
this:

- `signatureSavingStrategy` — whether a newly created signature is stored for
  reuse.
- `signatureCreationConfiguration` — the contents and layout of the signature
  creation sheet.

Like the rest of `NutrientViewConfiguration`, both are read when the viewer is
created. They apply to the bindings-based views (`NutrientView` /
`NutrientInstantView`); rebuild the view with a new configuration to change
them at runtime.

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Saving strategy

`signatureSavingStrategy` decides whether the signature the user just created
is persisted so it can be picked again later:

| Value | Behavior |
|-------|----------|
| `SignatureSavingStrategy.neverSave` | Signatures are never stored. |
| `SignatureSavingStrategy.alwaysSave` | Every new signature is stored. |
| `SignatureSavingStrategy.saveIfSelected` | Stored only if the user opts in. |

```dart
NutrientView(
  documentPath: path,
  configuration: NutrientViewConfiguration(
    signatureSavingStrategy: SignatureSavingStrategy.saveIfSelected,
  ),
)
```

Supported on **Android and iOS**. On **Web** it is ignored: the Web SDK manages
stored signatures through its own signature-storage API rather than a
create-time strategy.

> On iOS, a keychain-backed signature store is installed automatically when the
> strategy is `alwaysSave` or `saveIfSelected` (and only then) so that saving
> actually persists.

## Creation configuration

`signatureCreationConfiguration` takes a `SignatureCreationConfiguration` that
customizes the creation sheet:

```dart
NutrientView(
  documentPath: path,
  configuration: NutrientViewConfiguration(
    signatureCreationConfiguration: SignatureCreationConfiguration(
      // Offer only "draw" and "type" — drop the image tab.
      creationModes: [
        SignatureCreationMode.draw,
        SignatureCreationMode.type,
      ],
      // Three ink color presets.
      colorOptions: SignatureColorOptions(
        option1: SignatureColorPreset(color: Colors.black, id: 'black'),
        option2: SignatureColorPreset(color: Colors.indigo, id: 'indigo'),
        option3: SignatureColorPreset(color: Colors.teal, id: 'teal'),
      ),
      // Fonts offered on the "type" tab (iOS & Web).
      fonts: ['Zapfino', 'Noteworthy'],
      // Platform-specific layout.
      androidSignatureOrientation:
          NutrientAndroidSignatureOrientation.landscape,
      iosSignatureAspectRatio: const AspectRatio(aspectRatio: 1),
    ),
  ),
)
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `creationModes` | `List<SignatureCreationMode>?` | Which tabs the sheet offers, in order: `draw`, `image`, `type`. |
| `colorOptions` | `SignatureColorOptions?` | The three ink-color presets (`option1`/`option2`/`option3`). |
| `fonts` | `List<String>?` | Font family names offered for typed signatures. |
| `androidSignatureOrientation` | `NutrientAndroidSignatureOrientation?` | Dialog orientation on Android: `portrait`, `landscape`, `automatic`, `unlocked`. |
| `iosSignatureAspectRatio` | `AspectRatio?` | Aspect ratio of the signing area on iOS (a Flutter `AspectRatio` used as a value holder — only its ratio is read). |

### Color presets

Each preset is a `SignatureColorPreset` with a Flutter `Color` plus optional
localization for its accessibility label:

```dart
SignatureColorPreset(
  color: Colors.indigo,
  id: 'indigo',              // stable identifier
  defaultMessage: 'Indigo',  // human-readable label
  description: 'Indigo ink', // longer description
)
```

On Web, `fonts` must name families available to the page — declare custom faces
with a CSS `@font-face` rule (via a style sheet) so the family name resolves.

## Platform support

| Option | Android | iOS | Web |
|--------|---------|-----|-----|
| `signatureSavingStrategy` | ✅ | ✅ | ❌ storage is app-managed |
| `creationModes` | ✅ | ✅ | ✅ |
| `colorOptions` | ✅ | ✅ | ✅ |
| `fonts` | ❌ no native API | ✅ | ✅ |
| `androidSignatureOrientation` | ✅ | — | — |
| `iosSignatureAspectRatio` | — | ✅ | — |

Options for a platform that doesn't support them are ignored, so a single
cross-platform `SignatureCreationConfiguration` is safe to reuse everywhere —
set the platform-specific layout fields alongside the shared ones.

## See Also

- [Example: custom_configuration_example.dart](../catalog/lib/examples/custom_configuration_example.dart) — toggles the signature saving strategy and a custom creation UI live
- [NutrientViewConfiguration](view-configuration-guide.md) — the full viewer configuration these fields belong to
