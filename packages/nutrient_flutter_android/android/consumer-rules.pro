# Dart calls these through JNI by name, so R8 can't see that they're used.
-keep class com.nutrient.nutrient_flutter_android.AnnotationProviderBlocking {
    public static *;
}
-keep class com.nutrient.nutrient_flutter_android.FormProviderBlocking {
    public static *;
}
