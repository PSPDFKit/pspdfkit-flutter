/*
 *   Copyright © 2026 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.example

import io.flutter.embedding.android.FlutterAppCompatActivity

// Canary for the integration pattern our getting-started guide prescribes: customer
// apps subclass FlutterAppCompatActivity, which forces the app module's compiler to
// resolve its full supertype hierarchy (including io.nutrient types). Keep this class
// even though the manifest uses FlutterAppCompatActivity directly — without it, CI
// cannot catch classpath regressions that only customer builds hit.
class MainActivity : FlutterAppCompatActivity()
