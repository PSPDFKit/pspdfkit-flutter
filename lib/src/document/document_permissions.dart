///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

enum DocumentPermissions {
  /// Allow printing of document.
  printing,

  /// Modify the contents of the document.
  modification,

  /// Copy text and images from the document.
  extract,

  /// Add or modify text annotations, fill in interactive form fields.
  annotationsAndForms,

  /// Fill in existing interactive form fields (including signature fields).
  fillForms,

  /// Extract text and images from the document.
  extractAccessibility,

  /// Assemble the document (insert, rotate, or delete pages and create document outline items or thumbnail images).
  assemble,

  /// Print high quality.
  printHighQuality;
}
