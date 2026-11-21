# Intercepting the Signature Flow

Step into the built-in electronic signature flow from Dart. Decide the stroke
thickness and opacity a signature starts with, and where a new signature goes,
using UI of your own. The built-in signing UI stays as it is.

A `SignatureInterceptor` has two hooks, one for each decision point:

| Hook | Called | Returns |
|------|--------|---------|
| `onSignatureRequested` | Before the signing UI opens | The `SignatureStyle` to start with, or cancel |
| `onSignaturePlacementRequested` | After a signature is created or picked, before it is added | Keep the proposed position, move it, or add nothing |

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Setting an interceptor

Extend `SignatureInterceptor`, override the hooks you need, and pass it to
`controller.setSignatureInterceptor(...)`. Both hooks proceed unchanged by
default.

```dart
class BrandedSignatures extends SignatureInterceptor {
  BrandedSignatures(this.prefs);

  final SignaturePrefs prefs;

  @override
  Future<SignatureResponse> onSignatureRequested(SignatureRequest request) async {
    // Every signature starts with the thickness and opacity stored in the app.
    return SignatureResponse.proceed(
      style: SignatureStyle(thickness: prefs.thickness, opacity: prefs.opacity),
    );
  }
}

NutrientDocumentView(
  documentPath: path,
  onControllerReady: (controller) =>
      controller.setSignatureInterceptor(BrandedSignatures(prefs)),
)
```

Set it once per view, in `onControllerReady`. Call it again to replace the
interceptor, or pass `null` to remove it.

## Choosing the style before signing

`onSignatureRequested` runs when the user starts signing, from either entry
point: the signature tool in the annotation toolbar, or a tapped signature
form field. The signing UI waits until the returned future completes, so you
can show a sheet or dialog of your own first.

The `SignatureRequest` describes what is about to open:

| Field | Description |
|-------|-------------|
| `pageIndex` | The page the signature is for. |
| `formFieldName` | The fully qualified name of the signature form field being signed, or `null` when signing from the toolbar. `isFormField` is the shorthand. |
| `style` | The `SignatureStyle` the UI opens with unless you return another. |

Return one of the following:

- `SignatureResponse.proceed()` opens the UI with `request.style`.
- `SignatureResponse.proceed(style: ...)` opens it with your style.
- `SignatureResponse.cancel()` doesn't open it.

```dart
@override
Future<SignatureResponse> onSignatureRequested(SignatureRequest request) async {
  final style = await showModalBottomSheet<SignatureStyle>(
    context: context,
    builder: (_) => StylePicker(initial: request.style),
  );
  // Dismissing the sheet cancels the signature.
  if (style == null) return const SignatureResponse.cancel();
  return SignatureResponse.proceed(style: style);
}
```

A `SignatureStyle` has two values:

- `thickness` is the stroke width in PDF points, relative to the signing
  canvas. It must be greater than `0`.
- `opacity` runs from greater than `0` up to `1`, which is fully opaque. It
  applies to drawn, typed and image signatures alike.

When signatures are saved for reuse (see `signatureSavingStrategy` in
[Configuring Signatures](signature-configuration-guide.md)), the request comes
before the SDK lists the saved signatures. The style applies to a signature
created from there. You're asked once per signing flow, even when the user goes
from the saved signatures on to creating a new one.

## Deciding where the signature goes

`onSignaturePlacementRequested` runs once the user has created or picked a
signature, before it is added to the document. The `SignaturePlacementProposal`
has the following fields:

| Field | Description |
|-------|-------------|
| `pageIndex` | The page the SDK proposes. |
| `boundingBox` | The proposed bounding box on that page. |
| `pageSize` | The size of that page, for computing a position of your own. |
| `formFieldName` | The form field being signed, or `null` for a free-standing signature. `isFormField` is the shorthand. |

`boundingBox` and `pageSize` are in PDF page coordinates. That's the same
convention as `getVisibleRect`: the origin is the page's bottom-left corner,
and `Rect.top` is the smaller y value.

Return one of the following:

- `SignaturePlacementResponse.proceed()` adds the signature where proposed.
- `SignaturePlacementResponse.proceed(pageIndex: ..., boundingBox: ...)` adds
  it elsewhere. The signature is scaled to fit the box, so keep its aspect
  ratio close to the proposal's.
- `SignaturePlacementResponse.cancel()` adds nothing, for example when your app
  inserts the signature itself.

```dart
@override
Future<SignaturePlacementResponse> onSignaturePlacementRequested(
    SignaturePlacementProposal proposal) async {
  // A form field has a fixed location, so there is nothing to decide.
  if (proposal.isFormField) return const SignaturePlacementResponse.proceed();

  // Otherwise, put it in the bottom-right corner of the proposed page.
  final box = proposal.boundingBox;
  const margin = 24.0;
  return SignaturePlacementResponse.proceed(
    boundingBox: Rect.fromLTWH(
      proposal.pageSize.width - box.width - margin,
      margin,
      box.width,
      box.height,
    ),
  );
}
```

## Timing and lifecycle

- **Nothing happens until you answer.** The signing UI, or the new signature,
  waits for the returned future. Showing your own UI in between is expected.
- **Each request belongs to one signing flow.** A response that arrives after
  the view was disposed, or after a newer request replaced it, is ignored, and
  that signing flow is abandoned.

## Platform support

| | Android | iOS | Web |
|---|---|---|---|
| `onSignatureRequested` | ✅ | ✅ | — |
| `onSignaturePlacementRequested` | ✅ | ✅ | — |

On Web, `setSignatureInterceptor` is a no-op, because the Web SDK has no
equivalent hook. On Android and iOS it needs a Nutrient SDK version that has
the native signature hooks.

## See Also

- [Example: signature_interceptor_example.dart](../catalog/lib/examples/signature_interceptor_example.dart): thickness and opacity chosen in Flutter, then a sheet that decides the placement
- [Configuring Signatures](signature-configuration-guide.md): the creation UI's modes, colors and fonts, and the saving strategy
