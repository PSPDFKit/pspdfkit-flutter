package com.nutrient.nutrient_flutter_android

import com.pspdfkit.annotations.Annotation
import com.pspdfkit.annotations.AnnotationProvider
import kotlinx.coroutines.runBlocking

/**
 * Blocking calls to [AnnotationProvider]'s suspend functions, for the Dart
 * `AnnotationProviderBlocking`, which calls them through JNI. JNI can't call a suspend
 * function, and the Nutrient Android SDK removed its own blocking and RxJava companions
 * after 12.0.0.
 *
 * Each call blocks the calling thread until the SDK's call returns, as the SDK's companions did.
 * The SDK dispatches the work itself. Dart resolves this class by name, so it's kept by the
 * plugin's consumer R8 rules.
 */
internal object AnnotationProviderBlocking {

    @JvmStatic
    fun getAnnotations(provider: AnnotationProvider, pageIndex: Int): List<Annotation> =
        runBlocking { provider.getAnnotations(pageIndex) }

    @JvmStatic
    fun addAnnotationToPage(provider: AnnotationProvider, annotation: Annotation) {
        runBlocking { provider.addAnnotationToPage(annotation) }
    }

    @JvmStatic
    fun removeAnnotationFromPage(provider: AnnotationProvider, annotation: Annotation) {
        runBlocking { provider.removeAnnotationFromPage(annotation) }
    }

    @JvmStatic
    fun createAnnotationFromInstantJson(provider: AnnotationProvider, instantJson: String): Annotation =
        runBlocking { provider.createAnnotationFromInstantJson(instantJson) }
}
