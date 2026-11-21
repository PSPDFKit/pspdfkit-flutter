# Keep rules applied to apps that use nutrient_flutter when they build with R8 (Flutter release builds
# shrink by default). Keep only what is reached by name rather than by a normal Java/Kotlin reference.

# Called from Dart over JNI (jnigen bindings in nutrient_flutter_android) and looked up with
# Class.forName/getMethod by nutrient_flutter_android, which can't depend on this plugin at compile time.
-keep class com.pspdfkit.flutter.pspdfkit.PSPDFKitView { *; }
-keep class com.pspdfkit.flutter.pspdfkit.PSPDFKitView$Companion { *; }
-keep class com.pspdfkit.flutter.pspdfkit.ai.FlutterAiAssistantRegistry { *; }

# The Nutrient SDK detects Flutter with Class.forName on these names (HybridLicenseHelper).
-keepnames class com.pspdfkit.flutter.pspdfkit.PspdfkitPlugin
-keepnames class com.pspdfkit.flutter.pspdfkit.FlutterPdfActivity
