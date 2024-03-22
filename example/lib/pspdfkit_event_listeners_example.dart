import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitEventListenerExample extends StatelessWidget {
  final String documentPath;
  const PspdfkitEventListenerExample({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PspdfkitWidget(
          documentPath: documentPath,
          onPspdfkitWidgetCreated: (controller) {
            controller.addEventListener('annotations.create', (event) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Annotation created: $event'),
              ));
            });
            controller.addEventListener('annotations.update', (event) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Annotation updated: $event'),
              ));
            });
            controller.addEventListener('annotations.delete', (event) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Annotation deleted: $event'),
              ));
            });
            controller.addEventListener('annotations.focus', (event) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Annotation focused: $event'),
              ));
            });
            controller.addEventListener('viewState.currentPageIndex.change',
                (pageIndex) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('View state changed: $pageIndex'),
              ));
            });
          }),
    );
  }
}
