import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitZoomExample extends StatefulWidget {
  final String documentPath;

  const PspdfkitZoomExample({super.key, required this.documentPath});

  @override
  State<PspdfkitZoomExample> createState() => _PspdfkitZoomExampleState();
}

class _PspdfkitZoomExampleState extends State<PspdfkitZoomExample> {
  PspdfkitWidgetController? _controller;
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      // Do not resize the the document view on Android or
      // it won't be rendered correctly when filling forms.
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(),
      body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
              padding: PlatformUtils.isAndroid()
                  ? const EdgeInsets.only(top: kToolbarHeight)
                  : null,
              child: Stack(
                children: [
                  Expanded(
                    child: PspdfkitWidget(
                      documentPath: widget.documentPath,
                      onPspdfkitWidgetCreated: (view) {
                        setState(() {
                          _controller = view;
                        });
                      },
                      onPageChanged: (pageIndex) {
                        setState(() {
                          _pageIndex = pageIndex;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: _zoomToRect,
                          child: const Text('Zoom to rect'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: getZoomLevel,
                          child: const Text('Get zoom level'),
                        ),
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  void _zoomToRect() {
    var lastRect = const Rect.fromLTWH(492.83648681640625, 288.26708984375,
        88.66656494140625, 88.666259765625);
    _controller?.zoomToRect(18, lastRect).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    });
  }

  // This method is not available on iOS yet.
  void getZoomLevel() {
    _controller?.getZoomScale(_pageIndex).then((zoomLevel) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Zoom level: $zoomLevel')));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    });
  }
}
