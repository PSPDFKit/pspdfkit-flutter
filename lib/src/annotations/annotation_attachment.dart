/// Represents an attachment for an annotation
class AnnotationAttachment {
  final String id;

  /// The Base64 encoded binary data of the attachment
  final String binary;

  /// The MIME type of the attachment
  final String contentType;

  const AnnotationAttachment({
    required this.id,
    required this.binary,
    required this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'binary': binary,
      'contentType': contentType,
    };
  }

  factory AnnotationAttachment.fromJson(String id, Map<String, dynamic> json) {
    return AnnotationAttachment(
      id: id,
      binary: json['binary'] as String,
      contentType: json['contentType'] as String,
    );
  }
}

/// Mixin for annotations that can have attachments
mixin HasAttachment {
  /// The attachment associated with this annotation
  AnnotationAttachment? get attachment;

  /// Creates an attachment from JSON data
  AnnotationAttachment? createAttachmentFromJson(
      String attachmentId, Map<String, dynamic>? attachments) {
    if (attachments == null || !attachments.containsKey(attachmentId)) {
      return null;
    }

    return AnnotationAttachment.fromJson(
      attachmentId,
      attachments[attachmentId],
    );
  }
}
