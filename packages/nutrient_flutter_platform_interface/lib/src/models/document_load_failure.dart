///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';

/// Why a document failed to open in a Nutrient view.
///
/// Delivered to `NutrientInstantView.onDocumentLoadFailed`. A view that
/// reports this will never load — the viewer stays on its loading/error state
/// until the host app rebuilds the widget — so treat it as terminal and render
/// your own error UI (with a retry that remounts the view) rather than waiting
/// for a later success callback.
///
/// ```dart
/// NutrientInstantView(
///   serverUrl: serverUrl,
///   jwt: jwt,
///   onDocumentLoadFailed: (failure) {
///     setState(() => _error = failure.message);
///     if (failure.code == 'REQUEST_FAILED') {
///       // Offline or server unreachable — worth offering a retry.
///     }
///   },
/// )
/// ```
@immutable
class DocumentLoadFailure {
  /// A human-readable description of the failure, suitable for logging.
  ///
  /// Never empty: when the platform reports no message, this falls back to
  /// [type], then to a generic description.
  final String message;

  /// The native error type that caused the failure, when the platform
  /// reports one — for example `InstantDownloadException` or
  /// `InstantException` on Android.
  ///
  /// `null` on platforms (or code paths) that don't surface a type.
  final String? type;

  /// The Instant error code, when the failure came from Instant and the
  /// platform reports one — for example `REQUEST_FAILED` (server unreachable,
  /// typically offline), `AUTHENTICATION_FAILED` (rejected or expired JWT), or
  /// `INVALID_JWT`.
  ///
  /// These are the `InstantErrorCode` names from the native SDKs, passed
  /// through verbatim rather than remapped, so a code added natively still
  /// reaches you. `null` for non-Instant failures and on platforms that don't
  /// surface a code (currently iOS and Web).
  final String? code;

  /// Creates a [DocumentLoadFailure].
  const DocumentLoadFailure({
    required this.message,
    this.type,
    this.code,
  });

  /// Builds a [DocumentLoadFailure] from a platform-channel payload.
  ///
  /// Tolerates a missing or malformed map: anything unusable becomes `null`,
  /// and [message] falls back to [type] and then to a generic description, so
  /// a native-side regression degrades the detail rather than dropping the
  /// failure (which is the bug this callback exists to fix).
  factory DocumentLoadFailure.fromMap(Object? arguments) {
    final map = arguments is Map ? arguments : const <Object?, Object?>{};

    String? nonEmpty(Object? value) {
      final string = value is String ? value.trim() : null;
      return (string == null || string.isEmpty) ? null : string;
    }

    final type = nonEmpty(map['type']);
    final code = nonEmpty(map['code']);

    return DocumentLoadFailure(
      message: nonEmpty(map['message']) ?? type ?? 'Document failed to load.',
      type: type,
      code: code,
    );
  }

  @override
  String toString() {
    final details = [
      if (type != null) 'type: $type',
      if (code != null) 'code: $code',
    ].join(', ');
    return details.isEmpty
        ? 'DocumentLoadFailure($message)'
        : 'DocumentLoadFailure($message [$details])';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentLoadFailure &&
          other.message == message &&
          other.type == type &&
          other.code == code;

  @override
  int get hashCode => Object.hash(message, type, code);
}
