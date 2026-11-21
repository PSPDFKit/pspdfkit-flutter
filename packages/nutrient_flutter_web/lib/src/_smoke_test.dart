// Smoke test: try using generated bindings from real Dart code.
//
// This file is NOT part of the package's public API or build. It exists
// solely to validate that the generated `nutrient_web_bindings.g.dart`
// can be imported and consumed in idiomatic ways. Run:
//
//   dart analyze lib/src/_smoke_test.dart
//
// Findings (Nutrient SDK 1.14.0, generator state at commit 5d77006ecf3):
//
//   ✓ Color: static accessors (RED, BLUE, ...) work. Instance methods
//     (lighter, darker, toCSSValue, toHex) work.
//   ✗ Color: instance fields r/g/b/a NOT EMITTED. The TS source
//     declares them via `class Color extends Color_base` where
//     Color_base is a Record factory; the generator can't see through
//     the factory.
//   ✓ Rect, Point: inherited fields (left/top/width/height, x/y) ARE
//     emitted because TS source redeclares them on the class body.
//   ✗ Size: inherited width/height NOT emitted (same Record-factory
//     issue as Color, but TS source doesn't redeclare them).
//
// Conclusion: the generated bindings are USABLE for the subset of
// types whose TS source explicitly redeclares record-factory-inherited
// fields. Useless for the others.

// ignore_for_file: unused_import, unused_local_variable, unused_field
// ignore_for_file: unused_element

import 'dart:js_interop';

import 'generated/nutrient_web_bindings.g.dart' as nutrient_web;

class SmokeTest {
  // Test 1: Color statics + instance methods (WORKS).
  void testColor() {
    final red = nutrient_web.Color.RED;
    final lighter = red.lighter(20);
    final css = red.toCSSValue();
    final hex = red.toHex();
    print('css: $css, hex: $hex, lighter: ${lighter.toCSSValue()}');
  }

  // Test 1b: Color RGB fields (DOES NOT WORK — fields not emitted).
  // void testColorFields() {
  //   final red = nutrient_web.Color.RED;
  //   final r = red.r;  // analyzer error: getter 'r' isn't defined
  //   final g = red.g;
  //   final b = red.b;
  // }

  // Test 2: Rect read-access (WORKS).
  void testRect(nutrient_web.Rect rect) {
    final left = rect.left;
    final top = rect.top;
    final width = rect.width;
    final height = rect.height;
    print('rect: $left,$top,${width}x$height');
  }

  // Test 2b: Rect construction via constructor.
  void testRectConstruction() {
    // The generated constructor takes an IRect (also generated). IRect
    // is a structural object with optional left/top/width/height.
    // We'd need to construct it via dart:js_interop helpers.
    // Skipping for now — see whether IRect is generated as anonymous
    // type or extension type.
  }

  // Test 3: Point (WORKS).
  void testPoint(nutrient_web.Point point) {
    final x = point.x;
    final y = point.y;
    print('point: $x,$y');
  }

  // Test 4: Size (DOES NOT WORK — fields not emitted).
  // void testSize(nutrient_web.Size size) {
  //   final w = size.width;  // analyzer error: getter 'width' isn't defined
  //   final h = size.height;
  // }
}
