import 'package:flutter/material.dart';
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
  late MeasurementValueConfiguration _measurementValueConfiguration;

  @override
  void initState() {
    var scale = MeasurementScale(
        unitFrom: UnitFrom.inch,
        valueFrom: 1.0,
        unitTo: UnitTo.cm,
        valueTo: 2.54);
    var precision = MeasurementPrecision.fourDP;
    _measurementValueConfiguration = MeasurementValueConfiguration(
        name: 'Custom Scale', scale: scale, precision: precision);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Flexible(
            child: PspdfkitWidget(
              documentPath: widget.documentPath,
              configuration: PdfConfiguration(
                  measurementValueConfigurations: [
                    _measurementValueConfiguration
                  ],
                  pageLayoutMode: PspdfkitPageLayoutMode.single,
                  webConfiguration: PdfWebConfiguration(toolbarItems: [
                    ...Pspdfkit.defaultWebToolbarItems,
                    PspdfkitWebToolbarItem(
                        type: PspdfkitWebToolbarItemType.measurements)
                  ])),
            ),
          ),
        ],
      ),
    ));
  }
}
