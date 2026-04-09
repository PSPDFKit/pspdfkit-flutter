// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'utils/platform_utils.dart';

/// Demonstrates [NutrientViewController.convertViewPointToPdfPoint] and
/// [NutrientViewController.convertPdfPointToViewPoint].
///
/// Tap anywhere on the page to see the view → PDF coordinate conversion.
/// The round-trip result (PDF → view) is shown alongside so you can verify
/// the two conversions are inverse operations.
class CoordinateConversionExample extends StatefulWidget {
  final String documentPath;

  const CoordinateConversionExample({super.key, required this.documentPath});

  @override
  State<CoordinateConversionExample> createState() =>
      _CoordinateConversionExampleState();
}

class _CoordinateConversionExampleState
    extends State<CoordinateConversionExample> {
  NutrientViewController? _controller;

  // Last tap — view coordinates received from onPageClicked.
  Offset? _viewPoint;

  // Converted PDF coordinates.
  Offset? _pdfPoint;

  // Round-trip: PDF point converted back to view coordinates.
  Offset? _roundTripViewPoint;

  int _pageIndex = 0;
  bool _converting = false;

  Future<void> _onPageClicked(String documentId, int pageIndex, PointF? point,
      dynamic annotation) async {
    if (point == null || _controller == null) return;

    final tappedViewPoint = Offset(point.x, point.y);

    setState(() {
      _pageIndex = pageIndex;
      _viewPoint = tappedViewPoint;
      _pdfPoint = null;
      _roundTripViewPoint = null;
      _converting = true;
    });

    try {
      final pdfPoint = await _controller!
          .convertViewPointToPdfPoint(pageIndex, tappedViewPoint);

      final roundTripViewPoint =
          await _controller!.convertPdfPointToViewPoint(pageIndex, pdfPoint);

      setState(() {
        _pdfPoint = pdfPoint;
        _roundTripViewPoint = roundTripViewPoint;
        _converting = false;
      });
    } catch (e) {
      setState(() => _converting = false);
      if (kDebugMode) print('Coordinate conversion error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(title: const Text('Coordinate Conversion')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: PlatformUtils.isAndroid()
              ? const EdgeInsets.only(top: kToolbarHeight)
              : null,
          child: Stack(
            children: [
              NutrientView(
                documentPath: widget.documentPath,
                onViewCreated: (controller) =>
                    setState(() => _controller = controller),
                onPageChanged: (pageIndex) =>
                    setState(() => _pageIndex = pageIndex),
                onPageClicked: _onPageClicked,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ResultPanel(
                  pageIndex: _pageIndex,
                  viewPoint: _viewPoint,
                  pdfPoint: _pdfPoint,
                  roundTripViewPoint: _roundTripViewPoint,
                  converting: _converting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final int pageIndex;
  final Offset? viewPoint;
  final Offset? pdfPoint;
  final Offset? roundTripViewPoint;
  final bool converting;

  const _ResultPanel({
    required this.pageIndex,
    required this.viewPoint,
    required this.pdfPoint,
    required this.roundTripViewPoint,
    required this.converting,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: viewPoint == null
            ? const Text(
                'Tap anywhere on the page to convert coordinates.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              )
            : converting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('Converting…',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row('Page', 'page $pageIndex'),
                      _Row('View point (tap)', _fmt(viewPoint)),
                      if (pdfPoint != null) _Row('PDF point', _fmt(pdfPoint)),
                      if (roundTripViewPoint != null)
                        _Row('Round-trip view point', _fmt(roundTripViewPoint)),
                    ],
                  ),
      ),
    );
  }

  String _fmt(Offset? o) => o == null
      ? '—'
      : '(${o.dx.toStringAsFixed(2)}, ${o.dy.toStringAsFixed(2)})';
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
