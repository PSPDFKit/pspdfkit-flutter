///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:typed_data';

import 'package:jni/jni.dart';

import '../bindings/nutrient_android_sdk_bindings.dart';

/// Raw-JNI facade over `java.io.ByteArrayOutputStream`, which isn't in the
/// generated bindings — same `JClass.forName` idiom as
/// `AnnotationProviderBlocking`.
///
/// Used to capture the output of SDK formatters (`XfdfFormatter`,
/// `DocumentJsonFormatter`) that write to a `java.io.OutputStream`.
abstract final class ByteArrayOutputStreamJni {
  ByteArrayOutputStreamJni._();

  static final _class = JClass.forName(r'java/io/ByteArrayOutputStream');
  static final _ctor = _class.constructorId(r'()V');
  static final _toByteArrayId =
      _class.instanceMethodId(r'toByteArray', r'()[B');

  /// Creates an empty `ByteArrayOutputStream`. Cast with `as OutputStream`
  /// where a bindings `OutputStream` parameter is expected (extension types
  /// erase to `JObject`, so the cast is free). Caller releases.
  static JObject create() => _ctor.call<JObject>(_class, []);

  /// Copies [stream]'s current contents into Dart memory.
  static Uint8List toBytes(JObject stream) {
    final jBytes = _toByteArrayId.call(stream, JByteArray.type, []);
    // getRange returns a signed Int8List; reinterpret as unsigned so
    // multi-byte UTF-8 sequences survive a later decode.
    final bytes = jBytes.getRange(0, jBytes.length);
    jBytes.release();
    return Uint8List.sublistView(bytes);
  }
}

/// Builds a Dart-side [DataProvider] serving [bytes].
///
/// The `$DataProvider` mixin is jnigen's generated Dart-implementable
/// interface; `DataProvider.implement(...)` wraps it in a live JNI proxy
/// object that the SDK can call back into. Caller releases.
DataProvider bytesDataProvider(List<int> bytes, {required String uid}) =>
    DataProvider.implement($DataProvider(
      // The Java signature is `byte[] read(long size, long offset)` — the
      // SDK reads `size` bytes starting at `offset` (NOT offset, length).
      read: (int size, int offset) {
        final start = offset.clamp(0, bytes.length).toInt();
        final end = (offset + size).clamp(0, bytes.length).toInt();
        return JByteArray.of(bytes.sublist(start, end));
      },
      getSize: () => bytes.length,
      getUid: () => uid.toJString(),
      getTitle: () => null,
      release$1: () {},
    ));
