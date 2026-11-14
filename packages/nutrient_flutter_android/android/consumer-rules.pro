# Keep rules applied to apps that use nutrient_flutter_android when they build with R8 (Flutter release
# builds shrink by default). Keep only what is reached by name rather than by a normal Java/Kotlin reference.

# Dart calls these through JNI by name, so R8 can't see that they're used.
-keep class com.nutrient.nutrient_flutter_android.AnnotationProviderBlocking {
    public static *;
}
-keep class com.nutrient.nutrient_flutter_android.FormProviderBlocking {
    public static *;
}

# Called from Dart over JNI by name (jnigen bindings, lib/src/bindings/nutrient_android_sdk_bindings.dart).
# Keep this in sync with the plugin classes listed in jnigen.yaml.
-keep class com.nutrient.nutrient_flutter_android.FragmentContainerPlatformView { *; }
-keep class com.nutrient.nutrient_flutter_android.FragmentContainerPlatformView$Companion { *; }
