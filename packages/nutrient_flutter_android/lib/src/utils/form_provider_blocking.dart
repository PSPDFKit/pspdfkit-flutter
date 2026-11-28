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

/// Blocking calls to the Nutrient Android SDK's [FormProvider] lookups.
///
/// After Android SDK 12.0.0 they're Kotlin `suspend` functions, which the
/// generated bindings can't call, so they go through the plugin's blocking
/// Kotlin wrappers (`com.nutrient.nutrient_flutter_android.FormProviderBlocking`),
/// as `AnnotationProviderBlocking` does for annotations.
///
/// All returned JNI objects are owned by the caller — `release()` them (and the
/// elements of returned lists) when done.
abstract final class FormProviderBlocking {
  FormProviderBlocking._();

  static final _blockingClass = JClass.forName(
      r'com/nutrient/nutrient_flutter_android/FormProviderBlocking');

  static final _getFormFieldsId = _blockingClass.staticMethodId(
    r'getFormFields',
    r'(Lcom/pspdfkit/forms/FormProvider;)Ljava/util/List;',
  );

  static final _getFormFieldId = _blockingClass.staticMethodId(
    r'getFormFieldWithFullyQualifiedName',
    r'(Lcom/pspdfkit/forms/FormProvider;Ljava/lang/String;)Lcom/pspdfkit/forms/FormField;',
  );

  /// Returns every [FormField] in [provider]'s document.
  static JList<FormField?> getFormFields(FormProvider provider) {
    // As in AnnotationProviderBlocking.getAnnotations: call with
    // `JObject.type` and re-view the result as the typed list.
    final result = _getFormFieldsId.call(
      _blockingClass,
      JObject.type,
      [provider],
    );
    return result as JList<FormField?>;
  }

  /// Returns the [FormField] named [fullyQualifiedName], or null if there's
  /// none.
  static FormField? getFormFieldWithFullyQualifiedName(
    FormProvider provider,
    String fullyQualifiedName,
  ) {
    final name = fullyQualifiedName.toJString();
    try {
      return _getFormFieldId.callNullable(_blockingClass, JObject.type,
          [provider, name])?.as(FormField.type, releaseOriginal: true);
    } finally {
      name.release();
    }
  }
}
