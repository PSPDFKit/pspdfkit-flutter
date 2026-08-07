// /// Represents the line ending style for line annotations.
// enum LineEndingStyle {
//   /// No line ending style.
//   none,

//   /// Square line ending style.
//   square,

//   /// Circle line ending style.
//   circle,

//   /// Diamond line ending style.
//   diamond,

//   /// Open arrow line ending style.
//   openArrow,

//   /// Closed arrow line ending style.
//   closedArrow,

//   /// Butt line ending style.
//   butt,

//   /// Reversed open arrow line ending style.
//   reversedOpenArrow,

//   /// Reversed closed arrow line ending style.
//   reversedClosedArrow,

//   /// Slash line ending style.
//   slash,
// }

/// Represents the border style for annotations.
enum BorderStyle {
  /// Solid border style.
  solid,

  /// Dashed border style.
  dashed,

  /// Beveled border style.
  beveled,

  /// Inset border style.
  inset,

  /// Underline border style.
  underline,
}

/// Represents the text alignment for free text annotations.
enum TextAlignment {
  /// Left text alignment.
  left,

  /// Center text alignment.
  center,

  /// Right text alignment.
  right,

  /// Justified text alignment.
  justify,
}

/// Blend mode for annotations
enum BlendMode {
  normal,
  multiply,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
}

enum BorderEffect {
  cloudy,
  cloudyWithRidges,
  note,
  fileAttachment,
  graph,
  pushPin,
  star,
}

enum StampType {
  approved,
  notApproved,
  draft,
  final_,
  completed,
  confidential,
  forPublicRelease,
  notForPublicRelease,
  forComment,
  void_,
  preliminaryResults,
  informationOnly,
  rejected,
  accepted,
  initialHere,
  signHere,
  witness,
  asIs,
  departmental,
  experimental,
  expired,
  sold,
  topSecret,
  revised,
  rejectedWithText,
  custom,
}

extension StampTypeExtension on StampType {
  String get name {
    switch (this) {
      case StampType.approved:
        return 'Approved';
      case StampType.notApproved:
        return 'NotApproved';
      case StampType.draft:
        return 'Draft';
      case StampType.final_:
        return 'Final';
      case StampType.completed:
        return 'Completed';
      case StampType.confidential:
        return 'Confidential';
      case StampType.forPublicRelease:
        return 'ForPublicRelease';
      case StampType.notForPublicRelease:
        return 'NotForPublicRelease';
      case StampType.forComment:
        return 'ForComment';
      case StampType.void_:
        return 'Void';
      case StampType.preliminaryResults:
        return 'PreliminaryResults';
      case StampType.informationOnly:
        return 'InformationOnly';
      case StampType.rejected:
        return 'Rejected';
      case StampType.accepted:
        return 'Accepted';
      case StampType.initialHere:
        return 'InitialHere';
      case StampType.signHere:
        return 'SignHere';
      case StampType.witness:
        return 'Witness';
      case StampType.asIs:
        return 'AsIs';
      case StampType.departmental:
        return 'Departmental';
      case StampType.experimental:
        return 'Experimental';
      case StampType.expired:
        return 'Expired';
      case StampType.sold:
        return 'Sold';
      case StampType.topSecret:
        return 'TopSecret';
      case StampType.revised:
        return 'Revised';
      case StampType.rejectedWithText:
        return 'RejectedWithText';
      case StampType.custom:
        return 'Custom';
    }
  }
}
