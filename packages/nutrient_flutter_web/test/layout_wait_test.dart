///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_web/src/utils/layout_wait.dart';

void main() {
  // A 1 ms step and a 10 ms timeout: 10 visible checks before giving up.
  const step = Duration(milliseconds: 1);
  const timeout = Duration(milliseconds: 10);

  // A clock that moves on by [perStep] each time it's read: once when the
  // wait starts, then once after each step. Real timers would make the
  // counts below depend on the machine.
  Duration Function() clock([Duration perStep = step]) {
    var now = Duration.zero;
    return () => now += perStep;
  }

  group('waitForLayout', () {
    test('completes at once when already laid out', () async {
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () => ++checks > 0,
        isVisible: () => true,
        isActive: () => true,
        timeout: timeout,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isTrue);
      expect(checks, 1);
    });

    test('waits until the container is laid out', () async {
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () => ++checks >= 4,
        isVisible: () => true,
        isActive: () => true,
        timeout: timeout,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isTrue);
      expect(checks, 4);
    });

    test('gives up after the timeout of visible time', () async {
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () {
          checks++;
          return false;
        },
        isVisible: () => true,
        isActive: () => true,
        timeout: timeout,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isFalse);
      expect(checks, 11);
    });

    test("doesn't count time the page is hidden", () async {
      // Hidden for 30 checks, three times the timeout, then laid out once
      // visible again: a background tab that's brought to the front.
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () => ++checks > 35,
        isVisible: () => checks >= 30,
        isActive: () => true,
        timeout: timeout,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isTrue);
      expect(checks, 36);
    });

    test('counts the time that passed, not the steps', () async {
      // Each step takes 5 ms, like a throttled timer on a visible page, so
      // the 10 ms timeout runs out after two steps rather than ten.
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () {
          checks++;
          return false;
        },
        isVisible: () => true,
        isActive: () => true,
        timeout: timeout,
        step: step,
        elapsed: clock(const Duration(milliseconds: 5)),
      );

      expect(laidOut, isFalse);
      expect(checks, 3);
    });

    test('without a timeout, waits for as long as the view is active',
        () async {
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () => ++checks > 50,
        isVisible: () => true,
        isActive: () => true,
        timeout: null,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isTrue);
      expect(checks, 51);
    });

    test('stops once the view is gone', () async {
      var checks = 0;
      final laidOut = await waitForLayout(
        isLaidOut: () {
          checks++;
          return false;
        },
        isVisible: () => true,
        isActive: () => checks < 3,
        timeout: timeout,
        step: step,
        elapsed: clock(),
      );

      expect(laidOut, isFalse);
      expect(checks, 3);
    });
  });
}
