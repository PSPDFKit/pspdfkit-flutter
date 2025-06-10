import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class NutrientWebEventListenersExample extends StatefulWidget {
  final String documentPath;
  const NutrientWebEventListenersExample(
      {super.key, required this.documentPath});

  @override
  State<NutrientWebEventListenersExample> createState() =>
      _NutrientWebEventListenersExampleState();
}

class _NutrientWebEventListenersExampleState
    extends State<NutrientWebEventListenersExample> {
  final List<String> eventLogs = [];
  var selectedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PSPDFKit Event Listeners Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PspdfkitWidget(
                    documentPath: widget.documentPath,
                    onPspdfkitWidgetCreated: (controller) {
                      _setupEventListeners(controller);
                    }),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    child: Text(selectedText),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Event Logs:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        onPressed: () => setState(() => eventLogs.clear()),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: eventLogs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          eventLogs[eventLogs.length - 1 - index],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setupEventListeners(PspdfkitWidgetController controller) {
    controller.addWebEventListener(NutrientWebEvent.pagePress, (event) {
      _logEvent('Event triggered - Page pressed: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.formFieldValuesUpdate,
        (event) {
      _logEvent('Event triggered - Form field value updated: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.annotationsPress, (event) {
      _logEvent('Event triggered - Annotation pressed: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.documentChange, (event) {
      _logEvent('Event triggered - Document changed: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.annotationsBlur, (event) {
      _logEvent('Event triggered - Annotation blur: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.annotationsFocus, (event) {
      _logEvent('Event triggered - Annotation focus: $event');
    });

    controller.addEventListener(NutrientEvent.annotationsCreated, (event) {
      _logEvent('Event triggered - Annotation created: $event');
    });

    controller.addWebEventListener(NutrientWebEvent.formFieldsChange, (event) {
      _logEvent('Event triggered - Form field changed: $event');
    });
  }

  void _logEvent(String message) {
    setState(() {
      eventLogs.add("${DateTime.now().toIso8601String()}: $message");
    });
  }
}
