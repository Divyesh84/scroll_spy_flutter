import 'package:flutter/material.dart';
import 'package:scroll_spy_flutter/scroll_spy_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Scroll Spy Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Scroll Spy Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: DynamicScrollSpyWidget(
        headingList: [
          'Introduction',
          'Features',
          'Installation',
          'Basic Usage',
          'Advanced Usage',
          'API Reference',
          'Contributing',
        ],
        contentList: [
          _buildSection(
            'Introduction',
            'Flutter Dynamic Scroll Spy is a powerful widget that implements scroll spy functionality with a navigation bar and content area. Perfect for documentation, long-form content, and any UI that needs synchronized navigation with content.',
          ),
          _buildSection(
            'Features',
            '''
• Automatic highlighting of navigation items based on scroll position
• Smooth scrolling to content when navigation items are clicked
• Customizable styles for active and inactive navigation items
• Flexible layout with customizable width ratios
• Supports both automatic and programmatic scrolling
• Callbacks for navigation item selection and content visibility changes''',
          ),
          _buildSection(
            'Installation',
            '''
Add this to your package's pubspec.yaml file:

dependencies:
  flutter_dynamic_scroll_spy: ^0.0.1''',
          ),
          _buildSection(
            'Basic Usage',
            '''
Import the package:

import 'package:flutter_dynamic_scroll_spy/scroll_spy_flutter.dart';

Basic usage:

DynamicScrollSpyWidget(
  headingList: ['Section 1', 'Section 2', 'Section 3'],
  contentList: [
    Container(child: Text('Content for Section 1')),
    Container(child: Text('Content for Section 2')),
    Container(child: Text('Content for Section 3')),
  ],
)''',
          ),
          _buildSection(
            'Advanced Usage',
            '''
Advanced usage with all properties:

DynamicScrollSpyWidget(
  // Required properties
  headingList: ['Section 1', 'Section 2', 'Section 3'],
  contentList: [
    Container(child: Text('Content 1')),
    Container(child: Text('Content 2')),
    Container(child: Text('Content 3')),
  ],
  
  // Optional styling
  headingStyle: TextStyle(fontSize: 16),
  activeHeadingStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  contentPadding: EdgeInsets.all(16),
  headingPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  
  // Layout customization
  navigationFlex: 1,  // Takes up 1/4 of the width
  contentFlex: 3,    // Takes up 3/4 of the width
  
  // Callbacks
  onHeadingSelected: (index) {
    print('Heading \$index was selected');
  },
  onContentVisible: (index) {
    print('Content \$index is now most visible');
  },
)''',
          ),
          _buildSection(
            'API Reference',
            '''
Properties:

• headingList: List<String> - List of headings to show in the navigation bar
• contentList: List<Widget> - List of content widgets corresponding to each heading
• headingStyle: TextStyle? - Style for inactive heading text
• activeHeadingStyle: TextStyle? - Style for active heading text
• contentPadding: EdgeInsets? - Padding around content items
• headingPadding: EdgeInsets? - Padding around heading items
• navigationFlex: int - Flex value for navigation bar width (default: 1)
• contentFlex: int - Flex value for content area width (default: 3)
• onHeadingSelected: Function(int)? - Callback when heading is clicked
• onContentVisible: Function(int)? - Callback when content becomes most visible''',
          ),
          _buildSection(
            'Contributing',
            'Contributions are welcome! Please feel free to submit a Pull Request.',
          ),
        ],
        headingStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        activeHeadingStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        navigationFlex: 1,
        contentFlex: 3,
        headingPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        contentPadding: const EdgeInsets.all(24),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 