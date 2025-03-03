import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitAnnotationPresetCustomization extends StatefulWidget {
  final String documentPath;
  const PspdfkitAnnotationPresetCustomization(
      {Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<PspdfkitAnnotationPresetCustomization> createState() =>
      _PspdfkitAnnotationPresetCustomizationState();
}

class _PspdfkitAnnotationPresetCustomizationState
    extends State<PspdfkitAnnotationPresetCustomization> {
  PspdfkitWidgetController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PspdfkitWidget(
        documentPath: widget.documentPath,
        onPspdfkitWidgetCreated: (controller) {
          setState(() {
            _controller = controller;
          });
        },
        onPdfDocumentLoaded: (document) {
          try {
            _controller?.setAnnotationConfigurations(
              {
                AnnotationTool.inkPen: InkAnnotationConfiguration(
                  color: Colors.purple,
                  availableColors: [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow,
                    Colors.purple
                  ],
                  thickness: 30,
                  fillColor: Colors.white,
                  maxThickness: 30,
                  minThickness: 5,
                  maxAlpha: 1,
                  minAlpha: 0.1,
                  alpha: 1,
                ),
                AnnotationTool.freeText: FreeTextAnnotationConfiguration(
                  color: Colors.red,
                  fontSize: 40,
                  fillColor: Colors.white,
                  alpha: 0.5,
                ),
                AnnotationTool.arrow: LineAnnotationConfiguration(
                    color: Colors.green,
                    thickness: 20,
                    fillColor: Colors.white,
                    alpha: 0.5,
                    lineEndingStyle: LineEnd(
                        start: LineEndingStyle.square,
                        end: LineEndingStyle.openArrow)),
                AnnotationTool.highlight: MarkupAnnotationConfiguration(
                  color: Colors.red,
                ),
              },
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        },
      ),
    );
  }
}
