package com.nutrient.nutrient_flutter_android

import com.pspdfkit.forms.FormField
import com.pspdfkit.forms.FormProvider
import kotlinx.coroutines.runBlocking

/**
 * Blocking calls to [FormProvider]'s suspend lookups, for the Dart `FormProviderBlocking`, which
 * calls them through JNI. The Nutrient Android SDK made the provider suspend-only after 12.0.0,
 * and JNI can't call a suspend function.
 *
 * Each call blocks the calling thread until the SDK's call returns. The SDK dispatches the
 * work itself. Dart resolves this class by name, so it's kept by the plugin's consumer R8 rules.
 */
internal object FormProviderBlocking {

    @JvmStatic
    fun getFormFields(provider: FormProvider): List<FormField> =
        runBlocking { provider.getFormFields() }

    @JvmStatic
    fun getFormFieldWithFullyQualifiedName(provider: FormProvider, fullyQualifiedName: String): FormField? =
        runBlocking { provider.getFormFieldWithFullyQualifiedName(fullyQualifiedName) }
}
