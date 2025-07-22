import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class MeasurementsExample extends StatefulWidget {
  final String documentPath;

  const MeasurementsExample({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<MeasurementsExample> createState() => _MeasurementsExampleState();
}

class _MeasurementsExampleState extends State<MeasurementsExample> {
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
            child: NutrientView(
              documentPath: widget.documentPath,
              configuration: PdfConfiguration(
                  measurementValueConfigurations: [
                    _measurementValueConfiguration
                  ],
                  pageLayoutMode: PageLayoutMode.single,
                  webConfiguration: kIsWeb
                      ? PdfWebConfiguration(toolbarItems: [
                          ...Nutrient.defaultWebToolbarItems,
                          NutrientWebToolbarItem(
                              type: NutrientWebToolbarItemType.measurements)
                        ])
                      : null),
            ),
          ),
        ],
      ),
    ));
  }
}
