///
///  Copyright © 2019-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
part of pspdfkit;

/// Permission status enumeration used only by Android platform.
///
/// Used in the [Pspdfkit] class by [Pspdfkit.checkAndroidWriteExternalStoragePermission]
/// and [Pspdfkit.requestAndroidWriteExternalStoragePermission] for handling access
/// to external storage.
enum AndroidPermissionStatus {
  notDetermined,
  denied,
  authorized,
  deniedNeverAsk
}
