///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:jni/jni.dart';

/// Raw-JNI helpers for `java.io.File`.
///
/// jnigen does not bind `java.io.File` (it isn't part of the Nutrient SDK
/// surface, only appears in method signatures we need to call). We need a
/// `File` to pass into the synchronous `PdfProcessor.processDocument(...)`
/// overload — building it via `JClass.constructorId` keeps the surface
/// minimal and avoids pulling RxJava into the binding set.
class JniFile {
  static final _class = JClass.forName(r'java/io/File');
  static final _ctorPath = _class.constructorId(r'(Ljava/lang/String;)V');
  static final _idCreateTempFile = _class.staticMethodId(
    r'createTempFile',
    r'(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;',
  );
  static final _idGetAbsolutePath = _class.instanceMethodId(
    r'getAbsolutePath',
    r'()Ljava/lang/String;',
  );
  static final _idDelete = _class.instanceMethodId(r'delete', r'()Z');

  /// Creates a `File(path)`. Caller must release.
  static JObject fromPath(String path) {
    final jpath = path.toJString();
    try {
      return _ctorPath<JObject>(_class, [jpath]);
    } finally {
      jpath.release();
    }
  }

  /// Calls `File.createTempFile(prefix, suffix)` to get a fresh temp file in
  /// the JVM's default temp directory (`java.io.tmpdir`). Caller must release.
  static JObject createTempFile(String prefix, String suffix) {
    final jprefix = prefix.toJString();
    final jsuffix = suffix.toJString();
    try {
      return _idCreateTempFile<JObject, JObject>(
          _class, JObject.type, [jprefix, jsuffix]);
    } finally {
      jprefix.release();
      jsuffix.release();
    }
  }

  /// `file.getAbsolutePath()` as a Dart string.
  static String getAbsolutePath(JObject file) {
    final jstr = _idGetAbsolutePath(file, JString.type, []);
    try {
      return jstr.toDartString();
    } finally {
      jstr.release();
    }
  }

  /// `file.delete()` — best-effort cleanup. Ignores the return value.
  static void delete(JObject file) {
    _idDelete(file, jboolean.type, []);
  }
}
