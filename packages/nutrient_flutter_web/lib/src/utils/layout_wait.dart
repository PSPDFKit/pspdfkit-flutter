///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Checks [isLaidOut] every [step] until it holds, and completes with `true`.
///
/// Completes with `false` once [isLaidOut] still doesn't hold after the page
/// has been visible for [timeout], or as soon as [isActive] no longer holds.
/// With no [timeout], it waits for as long as [isActive] holds.
///
/// Only time the page is visible counts: a background tab lays nothing out,
/// however long it waits. That time is read from [elapsed], a [Stopwatch] by
/// default, rather than counted in steps, because a throttled timer can fire
/// long after [step] while the page stays visible.
Future<bool> waitForLayout({
  required bool Function() isLaidOut,
  required bool Function() isVisible,
  required bool Function() isActive,
  Duration? timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 16),
  Duration Function()? elapsed,
}) async {
  final stopwatch = Stopwatch()..start();
  final now = elapsed ?? () => stopwatch.elapsed;
  var visibleWait = Duration.zero;
  var last = now();
  while (isActive()) {
    if (isLaidOut()) return true;
    if (timeout != null && visibleWait >= timeout) return false;
    await Future<void>.delayed(step);
    final current = now();
    if (isVisible()) visibleWait += current - last;
    last = current;
  }
  return false;
}
