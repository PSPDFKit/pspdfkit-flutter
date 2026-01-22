import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class AnnotationPresetCustomization extends StatefulWidget {
  final String documentPath;
  const AnnotationPresetCustomization({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<AnnotationPresetCustomization> createState() =>
      _AnnotationPresetCustomizationState();
}

class _AnnotationPresetCustomizationState
    extends State<AnnotationPresetCustomization> {
  NutrientViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutrientView(
        documentPath: widget.documentPath,
        onViewCreated: (controller) {
          setState(() {
            _controller = controller;
          });
        },
        onDocumentLoaded: (document) {
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
                // Custom stamps with colors (iOS supports colors, Android supports subtitle)
                AnnotationTool.stamp: StampAnnotationConfiguration(
                  customStampItems: [
                    CustomStampItem(
                      title: 'APPROVED',
                      color: Colors.green,
                      subtitle: 'Verified',
                    ),
                    CustomStampItem(
                      title: 'REJECTED',
                      color: Colors.red,
                      subtitle: 'Not Approved',
                    ),
                    CustomStampItem(
                      title: 'PENDING',
                      color: Colors.orange,
                    ),
                    CustomStampItem(
                      title: 'DRAFT',
                      color: Colors.blue,
                    ),
                  ],
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
