///
///  Copyright @ 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
/// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'utils/platform_utils.dart';
import 'widgets/pdf_viewer_scaffold.dart';
import 'widgets/draggable_control_panel.dart';

/// Example annotations using the new annotation models
final exampleAnnotations = [
  // Ink annotation example.
  InkAnnotation(
      id: 'ink-annotation-1',
      bbox: [267.4, 335.1, 97.2, 10.3],
      createdAt: '2025-01-06T16:36:59+03:00',
      lines: InkLines(
        points: [
          [
            [269.4, 343.4],
            [308.4, 341.7],
            [341.2, 339.6],
            [358.8, 339.6],
            [360.9, 339.2],
            [362.6, 338.8],
            [361.7, 337.1],
          ]
        ],
        intensities: [
          [1.0, 0.43, 0.64, 0.83, 0.98, 0.99, 0.97]
        ],
      ),
      lineWidth: 4,
      opacity: 1.0,
      flags: [AnnotationFlag.print],
      creatorName: 'Nutrient Flutter',
      name: 'Ink annotation 1',
      isDrawnNaturally: false,
      strokeColor: const Color(0xFF2492FB),
      customData: {
        "phone": "123-456-7890",
        "email": "3XZ5y@example.com",
        "address": "123 Main St, Anytown, USA 12345",
      },
      pageIndex: 0),
  // Line annotation example.
  LineAnnotation(
      id: 'line-annotation-1',
      bbox: [200.0, 200.0, 300.0, 300.0],
      createdAt: '2025-01-06T16:36:59+03:00',
      startPoint: [200.0, 200.0],
      endPoint: [300.0, 300.0],
      strokeColor: const Color(0xFFFF0000),
      strokeWidth: 2,
      opacity: 0.8,
      lineCaps: const LineCaps(
        start: LineCapType.square,
        end: LineCapType.openArrow,
      ),
      flags: [AnnotationFlag.print, AnnotationFlag.readOnly],
      creatorName: 'Nutrient Flutter',
      name: 'Line-annotation-1',
      pageIndex: 0),

  // Square annotation example.
  SquareAnnotation(
      id: 'square-annotation-1',
      name: 'Square annotation 1',
      bbox: [200.0, 200.0, 300.0, 300.0],
      createdAt: '2025-01-06T16:36:59+03:00',
      strokeColor: const Color(0xFFFF0000),
      strokeWidth: 2,
      opacity: 0.8,
      flags: [AnnotationFlag.print, AnnotationFlag.readOnly],
      creatorName: 'Nutrient Flutter',
      pageIndex: 0),

  // Circle annotation example.

  // Polygon annotation example.
  PolygonAnnotation(
      id: 'polygon-annotation-1',
      name: 'Polygon annotation 1',
      bbox: [200.0, 200.0, 300.0, 300.0],
      createdAt: '2025-01-06T16:36:59+03:00',
      strokeColor: const Color(0xFFFF0000),
      strokeWidth: 2,
      opacity: 0.8,
      flags: [AnnotationFlag.print, AnnotationFlag.readOnly],
      creatorName: 'Nutrient Flutter',
      points: [
        [200.0, 200.0],
        [300.0, 200.0],
        [300.0, 300.0],
        [200.0, 300.0],
      ],
      pageIndex: 0),

  // Free text annotation example.
  FreeTextAnnotation(
    id: 'freetext-annotation-1',
    name: 'Free text annotation 1',
    bbox: [50.0, 650.0, 200.0, 50.0],
    createdAt: '2025-01-07T16:46:01+03:00',
    text: TextContent(
      format: TextFormat.plain,
      value: 'This is a free text annotation',
    ),
    fontColor: const Color(0xFF000000),
    fontSize: 20,
    font: 'sans-serif',
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
    backgroundColor: const Color(0xFFFF0000),
    horizontalTextAlign: HorizontalTextAlignment.left,
    verticalAlign: VerticalAlignment.top,
  ),

  // Highlight annotation example.
  HighlightAnnotation(
    id: 'highlight-annotation-1',
    name: 'Highlight annotation 1',
    bbox: [50.0, 450.0, 200.0, 20.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    color: const Color(0xFFFFEB3B),
    rects: [
      [50.0, 450.0, 200.0, 470.0],
    ],
    opacity: 0.5,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Note annotation example
  NoteAnnotation(
    id: 'note-annotation-1',
    name: 'Note annotation 1',
    bbox: [400.0, 450.0, 32.0, 32.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    text: TextContent(value: 'This is a note', format: TextFormat.plain),
    color: const Color(0xFFFF9800),
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Square shape annotation example
  SquareAnnotation(
    id: 'square-annotation-2',
    name: 'Square annotation 2',
    bbox: [50.0, 500.0, 100.0, 100.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    strokeColor: const Color(0xFF4CAF50),
    fillColor: const Color(0x334CAF50),
    strokeWidth: 2,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Circle shape annotation example
  CircleAnnotation(
    id: 'circle-annotation-1',
    name: 'Circle annotation 1',
    bbox: [200.0, 500.0, 100.0, 100.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    strokeColor: const Color(0xFF9C27B0),
    fillColor: const Color(0x339C27B0),
    strokeWidth: 2,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Strikeout annotation example
  StrikeoutAnnotation(
    id: 'strikeout-annotation-1',
    name: 'Strikeout annotation 1',
    bbox: [350.0, 500.0, 200.0, 20.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    color: const Color(0xFFF44336),
    rects: [
      [350.0, 500.0, 550.0, 520.0],
    ],
    opacity: 0.7,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Underline annotation example
  UnderlineAnnotation(
    id: 'underline-annotation-1',
    name: 'Underline annotation 1',
    bbox: [50.0, 550.0, 200.0, 20.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    color: const Color(0xFF2196F3),
    rects: [
      [50.0, 550.0, 250.0, 570.0],
    ],
    opacity: 0.7,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Squiggly annotation example
  SquigglyAnnotation(
    id: 'squiggly-annotation-1',
    name: 'Squiggly annotation 1',
    bbox: [300.0, 550.0, 200.0, 20.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    color: const Color(0xFF9C27B0),
    rects: [
      [300.0, 550.0, 500.0, 570.0],
    ],
    opacity: 0.7,
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Polygon annotation example
  PolygonAnnotation(
    id: 'polygon-annotation-2',
    name: 'Polygon annotation 2',
    bbox: [50.0, 600.0, 150.0, 150.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    strokeColor: const Color(0xFF795548),
    fillColor: const Color(0x33795548),
    strokeWidth: 2,
    points: [
      [50.0, 600.0],
      [200.0, 600.0],
      [125.0, 750.0],
    ],
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Polyline annotation example
  PolylineAnnotation(
    id: 'polyline-annotation-1',
    name: 'Polyline annotation 1',
    bbox: [250.0, 600.0, 150.0, 150.0],
    createdAt: '2025-01-07T16:49:18+03:00',
    strokeColor: const Color(0xFF607D8B),
    strokeWidth: 3,
    points: [
      [250.0, 600.0],
      [325.0, 750.0],
      [400.0, 600.0],
    ],
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),
  StampAnnotation(
      id: 'stamp-annotation-1',
      name: 'Stamp annotation 1',
      bbox: [50.0, 650.0, 50.0, 50.0],
      createdAt: '2025-01-07T16:49:18+03:00',
      stampType: StampType.custom,
      title: "Nutrient Flutter",
      subtitle: "Nutrient Custom Stamp",
      color: const Color(0xFF4CAF50),
      pageIndex: 0),

  // Link annotation example
  LinkAnnotation(
    id: 'link-annotation-1',
    name: 'Link annotation 1',
    bbox: [50.0, 700.0, 200.0, 30.0],
    createdAt: '2025-01-08T12:08:57+03:00',
    action: UriAction(
      uri: 'https://nutrient.io',
    ),
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Redaction annotation example
  RedactionAnnotation(
    id: 'redaction-annotation-1',
    name: 'Redaction annotation 1',
    rects: [
      [250.0, 700.0, 400.0, 730.0], // First redaction rectangle
    ],
    createdAt: '2025-01-08T12:08:57+03:00',
    overlayText: 'REDACTED',
    fillColor: const Color(0xFFE57373),
    fontColor: const Color.fromARGB(255, 0, 0, 0),
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // File annotation example
  FileAnnotation(
    id: 'file-annotation-1',
    name: 'File annotation 1',
    bbox: [50.0, 750.0, 32.0, 32.0],
    createdAt: '2025-01-08T12:08:57+03:00',
    iconName: FileIconName.paperClip,
    embeddedFile: EmbeddedFile(
      filePath: 'assets/example.txt',
      description: 'Example file',
      contentType: 'text/plain',
    ),
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Widget annotation example (form field)
  WidgetAnnotation(
    id: 'widget-annotation-1',
    name: 'Widget annotation 1',
    bbox: [100.0, 750.0, 200.0, 30.0],
    createdAt: '2025-01-08T12:08:57+03:00',
    fieldName: 'PHD',
    fieldType: 'text',
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
  ),

  // Image annotation example
  ImageAnnotation(
    id: 'image-annotation-1',
    name: 'Image annotation 1',
    bbox: [300.0, 750.0, 100.0, 100.0],
    createdAt: '2025-01-08T12:08:57+03:00',
    imageAttachmentId:
        '303c4baa3d6adfcb12cd71e7060d6714850fa9c5404270fde637e43606352580',
    pageIndex: 0,
    creatorName: 'Nutrient Flutter',
    attachment: const AnnotationAttachment(
        id: '303c4baa3d6adfcb12cd71e7060d6714850fa9c5404270fde637e43606352580',
        binary:
            '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCADIAMgDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5yooopFhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABXp/wE+HEfxC8SzjUHdNH09VkufLOGkLZCxg9s7WJPYA9Oo8wr6D/ZC8T2Wm67q+hX0qQzamsclsznG903AoPchsj6H6UAz34fCzwMunfYv+EV0nydu3cbcGT/AL+ffz75r5S+P/w1i+H3iG2fS2d9G1BWa3DklomXG5Ce4+YYJ5IODnGT9xV8p/tf+J7K+1TR/D9nIktxYeZPdFTny2fAVD6HAJI9xQyUz51ooooKCiiigAr1P4AfDWL4g+Ibl9UaRdG09Ve4EZ2tKzE7UB6gHBJPUYxxnI8sr6K/ZA8T2VjqmseH7yRIri/8ue1LHG9k3BkB7nBBA9jQDPdz8LPAzad9iPhXSRDt27vs4EmP+un38++c18mfHv4bx/D3xLANPkkfR9QVpLbzDloypAaMnvjcpB7gjryT90V8m/te+J7LUtd0jQrGVJptNEslyUOQjvtwnHcBST9R6UMlM+e6KKKCgooooAKKKKACiiigAooooAKKKKACiiigApUZkYOjFWBBBBwQR6e9dz8LPhlrXxEvpk00x21jbkCe8mBKIT0VQPvN7cADrjivVNd/ZevYNOaXRPEUV5eKufIuLbyRIcdA25sHtyMc9e9AXSPJR8U/HI077EPFGqeRjbnzfnA6f6z7361xkjvI7SSMzuxJZmJJYk9TnvnvU+o2Nzpt/cWV/C9vd27mOWJxgow4I+tV6APaPgt8EJ/HOnDWtau5bDRmYrEIVHmz4OGK5BCqDxnBOQR7133jD9mXTv7Lll8JaperfouUgvmR0lP93cqqVPuQf6j1j4KXdpe/Cnww9gVMcdjHE+3tIg2v/wCPBq7imS2z8zru3ms7ue2uo2iuIHaKSNxgo6nBU+hyMGoq7P4zXdpe/FPxNPpxU27XjgMmMMwwrEY4wWDfXrXGUigp0bvHIskbMkincrKSCCDnIPUHNNooA7M/FLxydP8AsX/CUap5GNufO+fH/XT7361xrszuXclmY5JPJJPOfrU+nWVzqV/b2VhC893cOIookHLs3AFfQ2h/svXs+nJLrXiKKzvHGTBb23nLHx0LFlyfXAx15oC6R840V3XxT+GWs/Du/iTUSlzYXBIgvIQQjkclSD91gO3I9CcHHC0BuFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAfbf7La2g+D2nG12+cbic3OOvmeYcZ99nl/pXrdfBPwm+KWr/Dq8m+xxpeaZckGeylYqCw6MjD7rep5yOMcAj1fXf2oWk0500Pw8Yb11wst1cb0jOOu0AbvzFMlo4L9qQWg+L+oG02+abeH7Rj/nps7/APANleS1a1XULrVtSub/AFGd7i8uZGlllfqzHr7D6dAOBgVVpFLQ7r4afFHxD8PpJU0iSKewmbdLZ3Kloy2Mblwcq2OMg4PfPFdb4x/aH8Va9pcthYwWmkRzKVkltyzSkHqAx+7+Az6EV4xRQFgPXJ61694P+AHi/wAR6XFqEps9KgmUPEl4zeYwPQ7VB28epz04rk/g3Y2mpfFHw1a6iqtbPeKWVwCHK5YKexBYAY/Cv0EFCQmz8/fiL8NfEXgCaP8Aty2ja0lbbFd27b4XbGducAg9eCB0OM4NcXX378bbC01D4U+J475VMcdlJOhPaRAWQ/8AfQFfAVAJ3PWv2XFtG+L1h9r2+aLeY2+7HMmzt77d9fblfmnpWoXWk6la3+nTvb3ltIssUqdVYdPY/ToRwcivo3Qv2oHj05E1zw8Zr1AAZbWfYkh9dpBK/mf6UA1c9E/akW0Pwe1E3W3zhPAbbPXzPMAOPfZ5n618SV6B8WPijq/xFvIftkaWemW7FoLKJiwDH+JmP3mwcdgB0A5Nef0DSCiiigAooooAKKKKACiiigAooooAKKKKACgAk4GSeg460V7/APsjeFLHV9f1XXNQiSZ9LEaWyuMhZH3fPj1AXA9Mk9qAbseVD4deMjp/20eGNY+zY3bvsr52+u3Gce+MVyrKVYhgQw4IIxj2Ir9Nq+T/ANrvwpY6bq+leILCJIZdR8yK6VRgPImCH/3iGIP+6O+aBJnzzRRRQMmsrqexvLe7tJWhuYJFlikTqjqQQw9wea+qvB/7S+iy6XFH4rsLy31FFw8logkikPqASCufTke9fJ9FANXPb/jb8cD410ttC8P2s9npDsGnlnIEs+CCF2gkKoPPUk4HTnPiCgswVQSx6Adz7UV9DfsieFLHUtX1XxBfxJNLpxjitVcZCOwJL/7wAGPqe+DRuGyPIz8OvGS6eb4+GNYFsF3bvsr5A9duM4/DFcqQQcHIPQ8dK/Tavkj9rjwnY6T4g0vXdPiSF9UEiXKIMBpE2nf9SHwfoO5NAkzwCiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV6n+z98R4Ph/4luV1RXOj6iqx3DIu4wsudsgHcDcwI9D3xg+WUUA0foUPiL4NOnfbR4o0b7PjOftabvptzuz7YzXyb+0J8Sbfx94htYdI3/wBjacrLC7jaZnbG58dhwAAfc8ZxXk9FAkrBRRRQMKKKKACvWP2eviTbeAfEF1Dq+/8AsbUVVZpEBYwOudr46kfMQQB6HnGD5PRQDVz9Cm+Ivg0ad9uPijR/s2M5+1pu+m3O7PtjNfJH7QPxHg+IHiW2XSlcaPpytHbs42mZmxukI7A7VAHXA7ZwPLKKBJWCiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/2Q==',
        contentType: 'image/jpeg'),
  )
];

class PspdfkitAnnotationsExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const PspdfkitAnnotationsExampleWidget(
      {Key? key, required this.documentPath, this.configuration})
      : super(key: key);

  @override
  State<PspdfkitAnnotationsExampleWidget> createState() =>
      _PspdfkitAnnotationsExampleWidgetState();
}

class _PspdfkitAnnotationsExampleWidgetState
    extends State<PspdfkitAnnotationsExampleWidget> {
  late NutrientViewController view;
  late PdfDocument? document;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCurrentPlatformSupported()) {
      return PdfViewerScaffold(
        documentPath: widget.documentPath,
        configuration: widget.configuration,
        appBar: AppBar(title: const Text('Annotations Example')),
        onPdfDocumentLoaded: (document) {
          setState(() {
            this.document = document;
          });
        },
        onNutrientWidgetCreated: (controller) {
          view = controller;
          controller.addEventListener(NutrientEvent.annotationsCreated,
              (event) {
            if (kDebugMode) {
              print('Annotations created: $event');
            }
          });
        },
        controlPanels: [
          DraggableControlPanel(
            title: 'Annotation Controls',
            initialPosition: const Offset(20, 100),
            initiallyExpanded: true,
            headerIcon: Icons.edit,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                    onPressed: _addAnnotations,
                    child: const Text('Add Annotations')),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _updateAnnotation,
                    child: const Text('Update Annotation')),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _getAnnotations,
                    child: const Text('Get Annotations')),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _getAllUnsavedAnnotations,
                    child: const Text('Get All Unsaved Annotations')),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _removeAnnotations,
                    child: const Text('Remove Annotations')),
              ],
            ),
          ),
        ],
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  Future<void> _addAnnotations() async {
    await document?.addAnnotations(exampleAnnotations);
  }

  Future<void> _updateAnnotation() async {
    try {
      // Find the first ink annotation
      final annotations = await document?.getAnnotations(0, AnnotationType.ink);
      if (annotations == null || annotations.isEmpty) {
        throw Exception('No ink annotations found');
      }

      // Get the annotation's name to look up its properties
      final inkAnnotation = annotations.first;
      final annotationName = inkAnnotation.name;
      if (annotationName == null || annotationName.isEmpty) {
        throw Exception('Ink annotation has no name');
      }

      // Get the annotation properties using the name
      final properties =
          await document?.getAnnotationProperties(0, annotationName);
      if (properties == null) {
        throw Exception('Could not get annotation properties');
      }

      // Update properties using the withUpdates method
      final updated = properties.withUpdates(
        lineWidth: 10,
        color: Colors.red,
      );

      // Save the updated properties
      await document?.saveAnnotationProperties(updated);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating annotation: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  Future<void> _getAnnotations() async {
    final annotations = await document?.getAnnotations(0, AnnotationType.all);
    if (annotations == null || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annotations'),
        content: SingleChildScrollView(
          child: Text(" $annotations"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _getAllUnsavedAnnotations() async {
    final annotations = await document?.getUnsavedAnnotations();
    if (annotations == null || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Annotations'),
        content: SingleChildScrollView(
          child: Text(" $annotations"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAnnotations() async {
    final annotations = await document?.getAnnotations(0, AnnotationType.all);
    if (annotations == null) return;
    for (var annotation in annotations) {
      await document?.removeAnnotation(annotation);
    }
  }
}
