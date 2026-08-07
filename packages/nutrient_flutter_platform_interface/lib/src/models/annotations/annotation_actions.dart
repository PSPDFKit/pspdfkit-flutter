/// Base class for all annotation actions
abstract class Action {
  /// Optional sub-action that will be executed after this action
  final Action? subAction;

  Action({this.subAction});

  Map<String, dynamic> toJson();

  /// Helper function to create an Action from JSON
  factory Action.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'goTo':
        return GoToAction.fromJson(json);
      case 'uri':
        return UriAction.fromJson(json);
      case 'submitForm':
        return SubmitFormAction.fromJson(json);
      default:
        throw ArgumentError('Unknown action type: ${json['type']}');
    }
  }
}

/// Action to navigate to a specific page and position
class GoToAction extends Action {
  /// The page index to navigate to (0-based)
  final int pageIndex;

  /// The type of destination (how the page should be displayed)
  final String destinationType;

  /// Optional parameters for the destination type:
  /// - If destinationType is "fitPage" or "fitPageBoundingBox": No parameters needed
  /// - If destinationType is "fitWidth" or "fitPageBoundingBoxWidth": Parameters contain the "top" value
  /// - If destinationType is "fitHeight" or "fitPageBoundingBoxHeight": Parameters contain the "left" value
  /// - If destinationType is "originAndZoom": Parameters contain "left", "top", and "zoom" values
  /// - If destinationType is "fitRectangle": Parameters contain "left", "top", "width", and "height" values
  final List<double>? params;

  GoToAction({
    required this.pageIndex,
    required this.destinationType,
    this.params,
    super.subAction,
  }) : assert(
          _validateDestinationTypeAndParams(destinationType, params),
          'Invalid parameters for destination type: $destinationType',
        );

  factory GoToAction.fromJson(Map<String, dynamic> json) {
    return GoToAction(
      pageIndex: json['pageIndex'] as int,
      destinationType: json['destinationType'] as String,
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      subAction: json['subAction'] != null
          ? Action.fromJson(json['subAction'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'goTo',
      'pageIndex': pageIndex,
      'destinationType': destinationType,
      if (params != null) 'params': params,
      if (subAction != null) 'subAction': subAction!.toJson(),
    };
  }

  static bool _validateDestinationTypeAndParams(
    String destinationType,
    List<double>? params,
  ) {
    switch (destinationType) {
      case 'fitPage':
      case 'fitPageBoundingBox':
        return params == null || params.isEmpty;
      case 'fitWidth':
      case 'fitPageBoundingBoxWidth':
      case 'fitHeight':
      case 'fitPageBoundingBoxHeight':
        return params != null && params.length == 1;
      case 'originAndZoom':
        return params != null && params.length == 3;
      case 'fitRectangle':
        return params != null && params.length == 4;
      default:
        return false;
    }
  }
}

/// Action to open a URL in a web browser
class UriAction extends Action {
  /// The URL to open
  final String uri;

  UriAction({
    required this.uri,
    super.subAction,
  });

  factory UriAction.fromJson(Map<String, dynamic> json) {
    return UriAction(
      uri: json['uri'] as String,
      subAction: json['subAction'] != null
          ? Action.fromJson(json['subAction'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'uri',
      'uri': uri,
      if (subAction != null) 'subAction': subAction!.toJson(),
    };
  }
}

/// Action to submit form data to a URL
class SubmitFormAction extends Action {
  /// The URL to submit the form data to
  final String url;

  /// Optional flags that control how the form data is submitted
  final List<String>? flags;

  SubmitFormAction({
    required this.url,
    this.flags,
    super.subAction,
  });

  factory SubmitFormAction.fromJson(Map<String, dynamic> json) {
    return SubmitFormAction(
      url: json['url'] as String,
      flags:
          (json['flags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      subAction: json['subAction'] != null
          ? Action.fromJson(json['subAction'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'submitForm',
      'url': url,
      if (flags != null) 'flags': flags,
      if (subAction != null) 'subAction': subAction!.toJson(),
    };
  }
}
