import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitAnnotationPresetCustomization extends StatelessWidget {
  final String documentPath;
  const PspdfkitAnnotationPresetCustomization(
      {Key? key, required this.documentPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PspdfkitWidget(
        documentPath: documentPath,
        onPspdfkitWidgetCreated: (controller) {
          try {
            controller.setAnnotationConfigurations(
              {
                AnnotationTool.inkPen: InkAnnotationConfiguration(
                  color: Colors.red,
                  availableColors: [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow,
                    Colors.black
                  ],
                  thickness: 10,
                  fillColor: Colors.white,
                  maxThickness: 20,
                  minThickness: 5,
                  maxAlpha: 1,
                  minAlpha: 0.1,
                  alpha: 0.5,
                ),
                AnnotationTool.freeText: FreeTextAnnotationConfiguration(
                  color: Colors.red,
                  fontSize: 40,
                  fillColor: Colors.white,
                  alpha: 0.5,
                ),
                AnnotationTool.arrow: LineAnnotationConfiguration(
                    color: Colors.red,
                    thickness: 10,
                    fillColor: Colors.white,
                    alpha: 0.5,
                    lineEndingStyle: {
                      'start': LineEndingStyle.openArrow,
                      'end': LineEndingStyle.closedArrow
                    }),
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
