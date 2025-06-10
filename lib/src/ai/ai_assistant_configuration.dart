class AIAssistantConfiguration {
  AIAssistantConfiguration({
    required this.serverUrl,
    required this.jwt,
    required this.sessionId,
    this.userId,
  });

  /// The URL where your AI Assistant server can be accessed
  final String serverUrl;

  /// JSON Web Token (JWT) for authentication
  final String jwt;

  /// A session identifier for the chat session
  final String? sessionId;

  /// Optional user identifier
  final String? userId;

  /// Converts this configuration to a map
  Map<String, String> toMap() {
    return {
      'serverUrl': serverUrl,
      'jwt': jwt,
      'sessionId': sessionId ?? '',
      'userId': userId ?? '',
    };
  }

  Map<String, String> toWebMap() {
    return {
      'backendUrl': serverUrl,
      'jwt': jwt,
      'sessionId': sessionId ?? '',
      'userId': userId ?? '',
    };
  }
}
