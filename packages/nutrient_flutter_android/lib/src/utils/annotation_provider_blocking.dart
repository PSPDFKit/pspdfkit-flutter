///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:jni/jni.dart';

import '../bindings/nutrient_android_sdk_bindings.dart';

/// Synchronous (blocking) facades for the Nutrient Android SDK's
/// [AnnotationProvider], which the generated jnigen bindings can't call
/// directly.
///
/// ## Why this exists — the Kotlin `suspend` trap
///
/// Most methods on `AnnotationProvider` in the Android SDK are Kotlin
/// `suspend` functions. On the JVM a `suspend` function takes a hidden
/// trailing `kotlin.coroutines.Continuation` parameter, but jnigen generates
/// the binding **without** it and emits a method id that doesn't exist on the
/// class — so calling e.g. `provider.getAnnotations(pageIndex)` through the
/// generated bindings throws `NoSuchMethodError` at runtime.
///
/// The SDK ships Java companions that wrap those `suspend` functions in
/// callable forms — `AnnotationProviderBlocking` (synchronous) and
/// `AnnotationProviderRxJava` (RxJava). This class bridges to them via raw JNI
/// (`JClass.forName(...)` + `staticMethodId(...)`), giving you working
/// synchronous calls.
///
/// ```dart
/// final provider = adapter.nativePdfDocument!.getAnnotationProvider();
/// final annotations = AnnotationProviderBlocking.getAnnotations(provider, 0);
/// for (var i = 0; i < annotations.length; i++) {
///   final a = annotations[i];
///   // … use a.toInstantJson() etc.
///   a.release();
/// }
/// annotations.release();
/// ```
///
/// If you hit the same `NoSuchMethodError` on another `suspend` API, apply the
/// same idiom: look up the SDK's `*Blocking` (or `*RxJava`) companion and call
/// it through `JClass.forName` / `staticMethodId`.
///
/// All returned JNI objects are owned by the caller — `release()` them (and the
/// elements of returned lists) when done.
abstract final class AnnotationProviderBlocking {
  AnnotationProviderBlocking._();

  static final _blockingClass =
      JClass.forName(r'com/pspdfkit/annotations/AnnotationProviderBlocking');

  static final _getAnnotationsId = _blockingClass.staticMethodId(
    r'getAnnotationsBlocking',
    r'(Lcom/pspdfkit/annotations/AnnotationProvider;I)Ljava/util/List;',
  );

  static final _removeAnnotationId = _blockingClass.staticMethodId(
    r'removeAnnotationFromPageBlocking',
    r'(Lcom/pspdfkit/annotations/AnnotationProvider;Lcom/pspdfkit/annotations/Annotation;)V',
  );

  static final _addAnnotationId = _blockingClass.staticMethodId(
    r'addAnnotationToPageBlocking',
    r'(Lcom/pspdfkit/annotations/AnnotationProvider;Lcom/pspdfkit/annotations/Annotation;)V',
  );

  static final _rxClass =
      JClass.forName(r'com/pspdfkit/annotations/AnnotationProviderRxJava');

  static final _createFromInstantJsonSingleId = _rxClass.staticMethodId(
    r'createAnnotationFromInstantJsonSingle',
    r'(Lcom/pspdfkit/annotations/AnnotationProvider;Ljava/lang/String;)Lio/reactivex/rxjava3/core/Single;',
  );

  static final _singleClass =
      JClass.forName(r'io/reactivex/rxjava3/core/Single');

  static final _blockingGetId = _singleClass.instanceMethodId(
    r'blockingGet',
    r'()Ljava/lang/Object;',
  );

  /// Returns every [Annotation] on [pageIndex] of [provider]'s document.
  ///
  /// The caller owns the returned list and its elements — `release()` each
  /// element you keep and the list itself.
  static JList<Annotation> getAnnotations(
    AnnotationProvider provider,
    int pageIndex,
  ) {
    // jni 1.0's container JTypes are non-generic (`JList.type` carries no
    // element type), so call with `JObject.type` and re-view the result as the
    // typed list — extension types erase to `JObject`, so the cast is free.
    final result = _getAnnotationsId.call(
      _blockingClass,
      JObject.type,
      [provider, pageIndex],
    );
    return result as JList<Annotation>;
  }

  /// Adds [annotation] to [provider]'s document, on the page the annotation
  /// itself carries (e.g. parsed from XFDF).
  static void addAnnotationToPage(
    AnnotationProvider provider,
    Annotation annotation,
  ) {
    _addAnnotationId.call(
      _blockingClass,
      // ignore: invalid_use_of_internal_member
      const jvoidType(),
      [provider, annotation],
    );
  }

  /// Removes [annotation] from its page in [provider]'s document.
  static void removeAnnotationFromPage(
    AnnotationProvider provider,
    Annotation annotation,
  ) {
    _removeAnnotationId.call(
      _blockingClass,
      // jni's `jvoidType` is `@internal`; it's the only way to express a void
      // return to `JMethodID.call`, so suppress per-use rather than file-wide.
      // ignore: invalid_use_of_internal_member
      const jvoidType(),
      [provider, annotation],
    );
  }

  /// Creates an [Annotation] from [instantJson] and **attaches it** to
  /// [provider]'s document, returning the new annotation.
  ///
  /// Because the annotation is already attached, do not also call
  /// `addAnnotationToPage` — that throws "already attached to a document". The
  /// caller owns the returned annotation; `release()` it when done.
  static Annotation createAnnotationFromInstantJson(
    AnnotationProvider provider,
    String instantJson,
  ) {
    final jsonStr = instantJson.toJString();
    try {
      final single = _createFromInstantJsonSingleId.call(
        _rxClass,
        JObject.type,
        [provider, jsonStr],
      );
      try {
        final result = _blockingGetId.call(
          single,
          JObject.type,
          [],
        );
        return result.as(Annotation.type, releaseOriginal: true);
      } finally {
        single.release();
      }
    } finally {
      jsonStr.release();
    }
  }
}
