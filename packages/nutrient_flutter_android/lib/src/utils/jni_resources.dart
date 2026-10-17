///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:jni/jni.dart';

/// Raw-JNI helpers for `android.content.res.Resources`.
///
/// jnigen did not generate a full Dart binding for `Resources` (it's an
/// Android framework type, not part of the Nutrient SDK surface). Only
/// [getIdentifier] is needed here — it resolves a string resource name to its
/// integer resource ID, which is required before calling the
/// `PdfActivityConfiguration$Builder.theme(int)` /
/// `PdfActivityConfiguration$Builder.themeDark(int)` JNI bindings.
class JniResources {
  static final _class = JClass.forName(r'android/content/res/Resources');

  static final _idGetIdentifier = _class.instanceMethodId(
    r'getIdentifier',
    r'(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I',
  );

  /// Calls `resources.getIdentifier(name, defType, defPackage)`.
  ///
  /// Returns the resolved resource ID, or `0` if the resource was not found.
  /// Callers must check for `0` and skip applying the resource in that case.
  ///
  /// [resources] must be a JNI reference to an `android.content.res.Resources`
  /// object (obtained via `Context.getResources()`). The caller is responsible
  /// for releasing [resources] after this call.
  static int getIdentifier(
    JObject resources,
    String name,
    String defType,
    String defPackage,
  ) {
    final jname = name.toJString();
    final jdefType = defType.toJString();
    final jdefPackage = defPackage.toJString();
    try {
      return _idGetIdentifier(
          resources, jint.type, [jname, jdefType, jdefPackage]);
    } finally {
      jname.release();
      jdefType.release();
      jdefPackage.release();
    }
  }
}
