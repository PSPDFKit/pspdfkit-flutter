import 'package:flutter/material.dart';
import 'package:pspdfkit_example/models/papsdkit_example_item.dart';

class ExampleListView extends StatelessWidget {
  final String frameworkVersion;
  final List<dynamic> widgets;

  const ExampleListView(this.frameworkVersion, this.widgets, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(top: 24),
          child: Center(
              child: Text(frameworkVersion,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)))),
      Expanded(
          child: ListView.separated(
              itemCount: widgets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final item = widgets[index];
                if (item is Widget) {
                  return item;
                } else if (item is String) {
                  return Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Text(item,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)));
                } else if (item is PspdfkitExampleItem) {
                  return ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      visualDensity: VisualDensity.standard,
                      title: Text(
                        item.title,
                      ),
                      subtitle: Text(
                        item.description,
                      ),
                      onTap: () => item.onTap());
                } else {
                  throw Exception('Unknown item type');
                }
              }))
    ]);
  }
}
