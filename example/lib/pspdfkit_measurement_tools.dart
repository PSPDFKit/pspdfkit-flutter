import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitMeasurementsExample extends StatefulWidget {
  final String documentPath;

  const PspdfkitMeasurementsExample({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<PspdfkitMeasurementsExample> createState() =>
      _PspdfkitMeasurementsExampleState();
}

class _PspdfkitMeasurementsExampleState
    extends State<PspdfkitMeasurementsExample> {
  late PspdfkitWidgetController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PSPDFKit Measurement Tools'),
        ),
        body: Stack(
          children: [
            PspdfkitWidget(
              documentPath: widget.documentPath,
              configuration: const {
                pageMode: 'single',
              },
              onPspdfkitWidgetCreated: (view) {
                setState(() {
                  _controller = view;
                });
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _controller.setMeasurementPrecision(MeasurementPrecision.fourDP);
              _controller.setMeasurementScale(MeasurementScale(
                  unitFrom: UnitFrom.cm,
                  valueFrom: 1.0,
                  unitTo: UnitTo.m,
                  valueTo: 100.0));
            },
            label: const Text('Set Measurement Scale & Precision')));
  }
}
