package com.example.example

import com.nutrient.nutrient_flutter_android.NutrientFlutterActivity

// Compile-only canary, never registered in the manifest (NutrientFlutterActivity is
// AppCompat-based and this example's themes are not). Subclassing it here forces the
// app module's compiler to resolve its full supertype hierarchy (AiAssistantProvider
// from io.nutrient, AppCompatActivity from androidx), which is what customer apps do
// per the bindings guide. Without it, CI cannot catch classpath regressions that only
// customer builds hit (see the 5.6.0 incident, J#HYB-1017).
class CanaryNutrientActivity : NutrientFlutterActivity()
