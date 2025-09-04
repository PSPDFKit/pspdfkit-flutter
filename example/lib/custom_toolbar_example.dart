// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'dart:io' show Platform;

/// Example demonstrating how to add custom toolbar items to Nutrient Flutter.
///
/// This example shows two key use cases:
/// 1. Standard custom toolbar items with custom icons
/// 2. Hiding the default annotation button and providing custom annotation controls
///
/// For a dedicated example focused solely on hiding the annotation button
/// with a custom annotation UI, see HiddenAnnotationButtonExample.
///
/// IMPORTANT: Custom icons must be added to the Android project:
/// 1. Add your icon files to the Android project in:
///    android/app/src/main/res/drawable/ directory
/// 2. Use the filename (without extension) as the iconName
///    For example, if you add 'my_custom_icon.xml' to the drawable folder,
///    use iconName: 'my_custom_icon'
///
/// For iOS custom icons:
/// - Use SF Symbol names directly as the iconName
///
/// NOTE: There are no predefined icons - you must add your own icons to the
/// Android project's drawable resources for Android support.
class CustomToolbarExample extends StatefulWidget {
  final String documentPath;

  const CustomToolbarExample({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<CustomToolbarExample> createState() => _CustomToolbarExampleState();
}

class _CustomToolbarExampleState extends State<CustomToolbarExample> {
  late NutrientViewController _controller;
  String _lastTappedItem = "None";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            child: NutrientView(
              documentPath: widget.documentPath,
              configuration: PdfConfiguration(
                // Standard toolbar hiding options
                androidShowOutlineAction: false,
                androidShowThumbnailGridAction: false,
                androidShowSearchAction: false,
                // NEW: Hide the default annotation creation button
                // This allows you to provide custom annotation controls
                androidShowAnnotationCreationAction: false,
                // Keep annotation editing functionality enabled
                enableAnnotationEditing: true,
              ),
              // Define custom toolbar items
              customToolbarItems: [
                // === CUSTOM ANNOTATION CONTROLS ===
                // Since we hid the default annotation button, provide custom annotation tools

                // EXAMPLE 1: Highlight tool with custom icon
                CustomToolbarItem(
                  identifier: 'custom_highlight',
                  title: 'Highlight',
                  iconName: Platform.isIOS ? 'highlighter' : 'highlight_icon',
                  iconColor: Colors.yellow,
                  position: ToolbarPosition.primary,
                ),

                // EXAMPLE 2: Note annotation tool
                CustomToolbarItem(
                  identifier: 'custom_note',
                  title: 'Add Note',
                  iconName: Platform.isIOS ? 'note.text' : 'note_icon',
                  iconColor: Colors.blue,
                  position: ToolbarPosition.primary,
                ),

                // EXAMPLE 3: Freehand drawing tool
                CustomToolbarItem(
                  identifier: 'custom_pen',
                  title: 'Draw',
                  iconName: Platform.isIOS ? 'pencil' : 'pen_icon',
                  iconColor: Colors.black,
                  position: ToolbarPosition.primary,
                ),
                CustomToolbarItem(
                  identifier: 'custom_share',
                  title: 'Share PDF',
                  iconName:
                      Platform.isIOS ? 'square.and.arrow.up' : 'share_icon',
                ),

                // EXAMPLE 5: Back navigation with custom icon
                CustomToolbarItem(
                  identifier: 'custom_back',
                  title: 'Back',
                  iconName: Platform.isIOS ? 'chevron.left' : 'back_icon',
                  position: ToolbarPosition.iosLeft,
                  isAndroidBackButton: true,
                ),
              ],
              // Handle custom toolbar item taps
              onCustomToolbarItemTapped: (String identifier) {
                setState(() {
                  _lastTappedItem = identifier;
                });

                // Handle different toolbar items
                switch (identifier) {
                  // These replace the default annotation creation button functionality
                  case 'custom_highlight':
                    _controller
                        .enterAnnotationCreationMode(AnnotationTool.highlight);
                    break;
                  case 'custom_note':
                    _controller
                        .enterAnnotationCreationMode(AnnotationTool.note);
                    break;
                  case 'custom_pen':
                    _controller
                        .enterAnnotationCreationMode(AnnotationTool.inkPen);
                    break;
                  case 'custom_share':
                    _showShareOptions();
                    break;
                  case 'custom_back':
                    Navigator.of(context).pop();
                    break;
                  case 'ios_settings':
                    _showSettingsDialog();
                    break;
                  case 'android_bookmark':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Bookmark feature would be implemented here'),
                      ),
                    );
                    break;
                  case 'custom_drawable':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Custom icon action would be implemented here'),
                      ),
                    );
                    break;
                }
              },
              // Store controller reference when created
              onViewCreated: (controller) {
                _controller = controller;
              },
            ),
          ),
          // Information panel showing the last tapped toolbar item
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Last tapped toolbar item: $_lastTappedItem',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '💡 Default annotation button is hidden - using custom annotation controls instead',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Example method to show a share options dialog
  void _showShareOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share PDF'),
        content: const Text('Choose how you want to share this document:'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement export functionality
              _controller.save().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document saved')),
                );
                Navigator.of(context).pop();
              });
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              // Implement export functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Export as option would be implemented here')),
              );
            },
            child: const Text('Export as...'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Example method to show a settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjust PDF viewing settings:'),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.color_lens, size: 20),
                SizedBox(width: 10),
                Text('Theme settings'),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.text_fields, size: 20),
                SizedBox(width: 10),
                Text('Text settings'),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.view_agenda, size: 20),
                SizedBox(width: 10),
                Text('View mode'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
