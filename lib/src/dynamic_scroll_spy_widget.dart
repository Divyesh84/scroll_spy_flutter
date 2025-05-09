import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

/// A widget that implements a scroll spy functionality with a navigation bar and content area.
///
/// The widget displays a list of headings in a navigation bar on the left side and
/// corresponding content on the right side. As the user scrolls through the content,
/// the widget automatically highlights the corresponding heading in the navigation bar.
/// Users can also click on headings to scroll to the corresponding content.
///
/// Example usage:
/// ```dart
/// DynamicScrollSpyWidget(
///   headingList: ['Section 1', 'Section 2', 'Section 3'],
///   contentList: [
///     Container(child: Text('Content 1')),
///     Container(child: Text('Content 2')),
///     Container(child: Text('Content 3')),
///   ],
///   navigationFlex: 1,
///   contentFlex: 3,
///   headingStyle: TextStyle(fontSize: 16),
///   activeHeadingStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
/// )
/// ```
class DynamicScrollSpyWidget extends StatefulWidget {
  /// Creates a DynamicScrollSpyWidget.
  ///
  /// The [headingList] and [contentList] must have the same length.
  const DynamicScrollSpyWidget({
    required this.headingList,
    required this.contentList,
    this.headingStyle,
    this.activeHeadingStyle,
    this.contentPadding,
    this.headingPadding,
    this.headingSpacing,
    this.contentSpacing,
    this.onHeadingSelected,
    this.onContentVisible,
    this.navigationFlex = 1,
    this.contentFlex = 3,
    super.key,
  }) : assert(headingList.length == contentList.length,
            'headingList and contentList must have the same length');

  /// List of headings to show in the navigation bar.
  ///
  /// Each heading corresponds to a content widget at the same index in [contentList].
  final List<String> headingList;

  /// List of widgets corresponding to each heading.
  ///
  /// Each widget is displayed in the content area and corresponds to a heading
  /// at the same index in [headingList].
  final List<Widget> contentList;

  /// Style for the heading text when not active.
  final TextStyle? headingStyle;

  /// Style for the heading text when active (currently visible in viewport).
  final TextStyle? activeHeadingStyle;

  /// Padding around each content widget.
  final EdgeInsets? contentPadding;

  /// Padding around each heading in the navigation bar.
  final EdgeInsets? headingPadding;

  /// Spacing between headings in the navigation bar.
  final double? headingSpacing;

  /// Spacing between content items.
  final double? contentSpacing;

  /// Callback function called when a heading is selected/clicked.
  ///
  /// The callback receives the index of the selected heading.
  final Function(int index)? onHeadingSelected;

  /// Callback function called when a content item becomes most visible in the viewport.
  ///
  /// The callback receives the index of the most visible content item.
  final Function(int index)? onContentVisible;

  /// Flex value for the navigation bar section (default: 1).
  ///
  /// Used to control the width ratio of the navigation bar relative to the content area.
  final int navigationFlex;

  /// Flex value for the content area section (default: 3).
  ///
  /// Used to control the width ratio of the content area relative to the navigation bar.
  final int contentFlex;

  @override
  State<DynamicScrollSpyWidget> createState() => _DynamicScrollSpyWidgetState();
}

class _DynamicScrollSpyWidgetState extends State<DynamicScrollSpyWidget> {
  final ScrollController _headingController = ScrollController();
  final ScrollController _contentController = ScrollController();
  final Map<int, GlobalKey> _contentKeysMap = {};
  final Map<int, GlobalKey> _headingKeys = {};
  final GlobalKey _contentListKey = GlobalKey();
  int _currentVisibleIndex = 0;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    // Initialize keys for all content items
    for (int i = 0; i < widget.contentList.length; i++) {
      _contentKeysMap[i] = GlobalKey();
      _headingKeys[i] = GlobalKey();
    }
    _contentController.addListener(_findVisibleContentItem);
  }

  @override
  void dispose() {
    _headingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _findVisibleContentItem() {
    if (_isProgrammaticScroll) return;

    final ancestorContext = _contentListKey.currentContext;
    if (ancestorContext == null) return;

    final ancestorBox = ancestorContext.findRenderObject() as RenderBox?;
    if (ancestorBox == null) return;

    int? mostVisibleIndex;
    double maxVisibilityPercentage = 0;

    // Check if we're at the start or end of the scroll
    bool isAtStart = _contentController.position.pixels <= 1;
    bool isAtEnd = _contentController.position.pixels >=
        _contentController.position.maxScrollExtent - 1;

    if (isAtStart) {
      mostVisibleIndex = 0;
    } else if (isAtEnd) {
      mostVisibleIndex = widget.contentList.length - 1;
    } else {
      _contentKeysMap.forEach((index, key) {
        final itemContext = key.currentContext;
        if (itemContext != null) {
          final itemBox = itemContext.findRenderObject() as RenderBox?;
          if (itemBox != null) {
            final itemOffset =
                itemBox.localToGlobal(Offset.zero, ancestor: ancestorBox);
            final itemTop = itemOffset.dy;
            final itemBottom = itemTop + itemBox.size.height;

            final visibleTop = itemTop.clamp(0.0, ancestorBox.size.height);
            final visibleBottom =
                itemBottom.clamp(0.0, ancestorBox.size.height);
            final visibleHeight =
                (visibleBottom - visibleTop).clamp(0.0, itemBox.size.height);

            // Calculate visibility percentage
            final visibilityPercentage = visibleHeight / itemBox.size.height;

            if (visibilityPercentage > maxVisibilityPercentage) {
              maxVisibilityPercentage = visibilityPercentage;
              mostVisibleIndex = index;
            }
          }
        }
      });
    }

    if (_currentVisibleIndex != mostVisibleIndex && mostVisibleIndex != null) {
      setState(() {
        _currentVisibleIndex = mostVisibleIndex!;
      });
      widget.onContentVisible?.call(_currentVisibleIndex);
      if (!_isHeadingVisible(_currentVisibleIndex)) {
        _scrollToHeading(_currentVisibleIndex);
      }
    }
  }

  bool _isHeadingVisible(int index) {
    final headingContext = _headingKeys[index]?.currentContext;
    if (headingContext == null) return true;

    final RenderBox? box = headingContext.findRenderObject() as RenderBox?;
    if (box == null) return true;

    final RenderBox? listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return true;

    final itemOffset = box.localToGlobal(Offset.zero, ancestor: listBox);
    final itemTop = itemOffset.dy;
    final itemBottom = itemTop + box.size.height;
    final viewportHeight = listBox.size.height;

    return !(itemTop < 0 || itemBottom > viewportHeight);
  }

  Future<void> _scrollToHeading(int index) async {
    if (index < 0 || index >= _headingKeys.length) return;

    final headingContext = _headingKeys[index]?.currentContext;
    if (headingContext != null) {
      await Scrollable.ensureVisible(
        headingContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _scrollToContent(int index) async {
    if (index < 0 || index >= _contentKeysMap.length) return;

    final itemContext = _contentKeysMap[index]?.currentContext;
    if (itemContext != null) {
      _isProgrammaticScroll = true;
      await Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentVisibleIndex = index;
      });
      widget.onContentVisible?.call(_currentVisibleIndex);
      _isProgrammaticScroll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation bar with headings
        Expanded(
          flex: widget.navigationFlex,
          child: SingleChildScrollView(
            controller: _headingController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.headingList.mapIndexed((index, heading) {
                return Padding(
                  key: _headingKeys[index],
                  padding: widget.headingPadding ?? const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      _scrollToContent(index);
                      widget.onHeadingSelected?.call(index);
                    },
                    child: Text(
                      heading,
                      style: _currentVisibleIndex == index
                          ? widget.activeHeadingStyle
                          : widget.headingStyle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Vertical divider
        const VerticalDivider(width: 1),
        // Content area
        Expanded(
          flex: widget.contentFlex,
          child: SingleChildScrollView(
            key: _contentListKey,
            controller: _contentController,
            child: Column(
              children: widget.contentList.mapIndexed((index, content) {
                return Padding(
                  key: _contentKeysMap[index],
                  padding: widget.contentPadding ?? const EdgeInsets.all(16.0),
                  child: content,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
