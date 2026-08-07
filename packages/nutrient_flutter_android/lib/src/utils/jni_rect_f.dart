///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

import 'package:jni/jni.dart';

/// Raw-JNI helpers for `android.graphics.RectF`.
///
/// jnigen did not generate Dart bindings for `RectF` (it's a standard
/// Android framework type, not part of the Nutrient SDK surface). The
/// adapter needs to construct a `RectF` to pass into `PdfFragment.zoomTo`
/// and read back from `PdfFragment.getVisiblePdfRect`, so we go through
/// `JClass.constructorId` / `JClass.instanceFieldId` directly.
class JniRectF {
  static final _class = JClass.forName(r'android/graphics/RectF');
  static final _ctorEmpty = _class.constructorId(r'()V');
  static final _ctorLtrb = _class.constructorId(r'(FFFF)V');
  static final _idLeft = _class.instanceFieldId(r'left', r'F');
  static final _idTop = _class.instanceFieldId(r'top', r'F');
  static final _idRight = _class.instanceFieldId(r'right', r'F');
  static final _idBottom = _class.instanceFieldId(r'bottom', r'F');

  /// Creates an empty `RectF` (all zeros). Caller must release.
  static JObject empty() {
    return _ctorEmpty<JObject>(_class, []);
  }

  /// Creates a `RectF(left, top, right, bottom)`. Caller must release.
  static JObject ltrb(double left, double top, double right, double bottom) {
    // `RectF`'s constructor takes four `float`s. The high-level constructor
    // call infers the JNI type from each Dart value, and a bare `double` is
    // marshalled into the `jvalue.d` (64-bit) slot — but the JVM reads
    // `jvalue.f` (32-bit) for a `float` parameter, so the values arrive as
    // garbage (a degenerate rect the SDK then clamps to max zoom). Wrap each
    // in [JValueFloat] so it lands in the `float` slot.
    return _ctorLtrb<JObject>(_class, [
      JValueFloat(left),
      JValueFloat(top),
      JValueFloat(right),
      JValueFloat(bottom),
    ]);
  }

  /// Creates a `RectF` from a Flutter [Rect] (LTWH) by converting to LTRB.
  /// Caller must release.
  static JObject fromFlutterRect(Rect rect) {
    return ltrb(rect.left, rect.top, rect.right, rect.bottom);
  }

  /// Reads the four floats out of a `RectF` and returns a Flutter [Rect].
  /// Does not release [rectF].
  static Rect toFlutterRect(JObject rectF) {
    final left = _idLeft.get(rectF, jfloat.type);
    final top = _idTop.get(rectF, jfloat.type);
    final right = _idRight.get(rectF, jfloat.type);
    final bottom = _idBottom.get(rectF, jfloat.type);
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
