import 'package:flutter/material.dart';
import 'package:nutrient_example/utils/jwt_util.dart';
import 'package:nutrient_example/widgets/pdf_viewer_scaffold.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:uuid/uuid.dart';

/// A minimal example demonstrating AI Assistant with automatic configuration
class NutrientAiAssistantExample extends StatefulWidget {
  final String documentPath;
  const NutrientAiAssistantExample({super.key, required this.documentPath});

  @override
  State<NutrientAiAssistantExample> createState() =>
      _NutrientAiAssistantExampleState();
}

class _NutrientAiAssistantExampleState
    extends State<NutrientAiAssistantExample> {
  final _uuid = const Uuid();

  // Configuration values
  final String _serverUrl = '<your-server-url>';
  String _jwt = '';
  String _sessionId = 'random-session';
  final String _userId = 'random-user';

  // API state
  bool _isLoading = false;

  // Current configuration applied to the PDF viewer
  late AIAssistantConfiguration _currentConfig;
  var defaultWebToolbarItems = Nutrient.defaultWebToolbarItems;

  @override
  void initState() {
    super.initState();

    // Initialize configuration process
    _initializeConfiguration();
  }

  /// Initialize the configuration asynchronously
  Future<void> _initializeConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate JWT
      _jwt = JwtUtil.generateToken(userId: _userId);

      // Create configuration
      _currentConfig = AIAssistantConfiguration(
        serverUrl: _serverUrl,
        jwt: _jwt,
        sessionId: _sessionId,
        userId: _userId,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error, fall back to default configuration
      _sessionId = _uuid.v4();
      _jwt = JwtUtil.generateToken(userId: _userId);

      _currentConfig = AIAssistantConfiguration(
        serverUrl: _serverUrl,
        jwt: _jwt,
        sessionId: _sessionId,
        userId: _userId,
      );

      setState(() {
        _isLoading = false;
      });

      // Show error in console
      debugPrint('Error initializing AI Assistant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? // Show loading indicator while configuring
        const Positioned(
            top: 80,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing AI Assistant...'),
                  ],
                ),
              ),
            ),
          )
        : PdfViewerScaffold(
            documentPath: widget.documentPath,
            configuration: PdfConfiguration(
              // Add AI Assistant configuration
              aiAssistantConfiguration: _currentConfig,
              // Enable AI Assistant on Android
              androidEnableAiAssistant: true,
              // Enable AI Assistant on iOS
              iOSLeftBarButtonItems: ['aiAssistantButtonItem'],
              webConfiguration: PdfWebConfiguration(
                instant: true,
                toolbarItems: [
                  // Add AI Assistant button to the toolbar on web
                  NutrientWebToolbarItem(
                    type: NutrientWebToolbarItemType.aiAssistant,
                  ),
                  ...defaultWebToolbarItems,
                ],
              ),
            ),
            appBar: AppBar(
              title: const Text('AI Assistant Example'),
            ),
          );
  }
}
