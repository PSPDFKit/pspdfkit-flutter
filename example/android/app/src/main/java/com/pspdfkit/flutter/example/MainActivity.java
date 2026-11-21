package com.pspdfkit.flutter.example;

import io.flutter.embedding.android.FlutterAppCompatActivity;

// Canary for the integration pattern our getting-started guide prescribes: customer
// apps subclass FlutterAppCompatActivity, which forces the app module's compiler to
// resolve its full supertype hierarchy. Keep this class even though the manifest names
// FlutterAppCompatActivity directly — without a subclass, CI cannot catch
// dependency-scope regressions that only customer builds hit (J#HYB-1017).
public class MainActivity extends FlutterAppCompatActivity {}
