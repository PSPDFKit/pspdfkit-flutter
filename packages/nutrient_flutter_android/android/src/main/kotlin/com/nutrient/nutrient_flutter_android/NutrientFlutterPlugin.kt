package com.nutrient.nutrient_flutter_android

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** NutrientFlutterPlugin */
class NutrientFlutterPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Register empty fragment container view (for JNI-based fragment management)
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(
        "nutrient_fragment_container",
        FragmentContainerViewFactory(flutterPluginBinding.binaryMessenger)
      )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // Clean up if needed
  }
}


