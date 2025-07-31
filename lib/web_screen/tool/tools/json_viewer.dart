import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heys_dev_web/web_screen/tool/share/master_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../common/util/utils.dart';

// --- BuildContext 확장: 모바일 여부 판별 ---
// extension MediaQueryExt on BuildContext {
//   bool get isMobile {
//     final userAgent = html.window.navigator.userAgent.toLowerCase();
//     // UserAgent로 디바이스 체크
//     return userAgent.contains('mobile') ||
//         userAgent.contains('android') ||
//         userAgent.contains('iphone') ||
//         userAgent.contains('ipad') ||
//         MediaQuery.of(this).size.width < 700;
//   }
// }

class JsonViewerScreen extends HookConsumerWidget {
  static String routeName = "json-viewer";

  const JsonViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HeysTool.setMetaTags(
      title: 'JSON Viewer & Formatter – heys.dev',
      description:
          'Free, fast, and easy-to-use online JSON Viewer & Formatter. Instantly validate, beautify, and visualize your JSON data in a beautiful tree view with one click. No login required!',

      url: 'https://heys.dev/json-viewer',
      keywords:
          'json viewer, json formatter, online, dev tools, heys.dev, beautify, validate, tree view',
      siteName: 'heys.dev',
      ogType: 'website',
      twitterCard: 'summary_large_image',
    );
    return MasterScreen(child: JsonViewerHome());
  }
}

class JsonViewerHome extends StatefulWidget {
  const JsonViewerHome({super.key});

  @override
  State<JsonViewerHome> createState() => _JsonViewerHomeState();
}

class _JsonViewerHomeState extends State<JsonViewerHome>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  dynamic _parsed;
  String? _error;
  late TabController _tabController;
  int _currentLine = 1;
  int _currentColumn = 1;
  bool _expandAll = false;
  bool _hovered = false;

  final ScrollController _treeHController = ScrollController();
  final ScrollController _treeVController = ScrollController();
  bool _showTooltip = false;

  @override
  void dispose() {
    _treeHController.dispose();
    _treeVController.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inputController.text =
        '{\n  "hello": "world",\n  "tags": ["json", "test"]\n}';
    _tabController = TabController(length: 2, vsync: this);

    _inputController.addListener(() {
      _updateCursorPos();
      _autoParseJson();
    });
  }

  void _updateCursorPos() {
    final pos = _inputController.selection.baseOffset;
    final text = _inputController.text;
    int line = 1, col = 1, p = 0;
    for (; p < pos && p < text.length; ++p) {
      if (text[p] == '\n') {
        line++;
        col = 1;
      } else {
        col++;
      }
    }
    setState(() {
      _currentLine = line;
      _currentColumn = col;
    });
  }

  void _autoParseJson() {
    try {
      final result = jsonDecode(_inputController.text);
      setState(() {
        _parsed = result;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _parsed = null;
      });
    }
  }

  void _parseAndShowError() {
    setState(() {
      _error = null;
      try {
        _parsed = jsonDecode(_inputController.text);
      } catch (e) {
        final msg = e.toString();
        _error = "⚠️ JSON parse error: $msg";
        final reg = RegExp(r'position (\d+) \(line (\d+) column (\d+)\)');
        final match = reg.firstMatch(msg);
        if (match != null) {
          final pos = int.tryParse(match.group(1) ?? '') ?? 0;
          final line = int.tryParse(match.group(2) ?? '') ?? 1;
          final col = int.tryParse(match.group(3) ?? '') ?? 1;
          _selectErrorPosition(pos, line, col);
        }
        _parsed = null;
      }
    });
  }

  void _selectErrorPosition(int pos, int line, int col) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputController.selection = TextSelection(
        baseOffset: pos,
        extentOffset: pos + 1,
      );
      FocusScope.of(context).requestFocus(_inputFocus);
      setState(() {
        _currentLine = line;
        _currentColumn = col;
      });
    });
  }

  void _copyFormatted({bool minified = false}) {
    try {
      final dynamic jsonVal = jsonDecode(_inputController.text);
      final json = minified
          ? jsonEncode(jsonVal)
          : const JsonEncoder.withIndent('  ').convert(jsonVal);
      Clipboard.setData(ClipboardData(text: json));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(minified ? 'Minified copied!' : 'Pretty JSON copied!'),
        ),
      );
    } catch (_) {}
  }

  Future<void> _pickFile() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.json,application/json';
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      final reader = html.FileReader();
      reader.readAsText(file!);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _inputController.text = reader.result as String;
        });
      });
    });
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
        setState(() {
          _inputController.text = data.text!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty!')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to access clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    print('isMobile: $isMobile'); // 디버깅용
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Viewer / Formatter'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F3F4),
        elevation: 0,
      ),
      body: isMobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      children: [
        // 입력창
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              color: const Color(0xFFF9F3F4),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Open'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(30, 40),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _pickFile,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.paste, size: 18),
                            label: const Text('Paste'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(30, 40),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _pasteFromClipboard,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocus,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '{ "hello": "world" }',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onTap: _updateCursorPos,
                        onChanged: (_) => _updateCursorPos(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 결과탭
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              color: const Color(0xFFF4E8EC),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.account_tree), text: "Tree"),
                      Tab(icon: Icon(Icons.code), text: "Text"),
                    ],
                    indicatorColor: Colors.indigo,
                    labelColor: Colors.indigo,
                    unselectedLabelColor: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTreeWithTooltip(context),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SelectableText(
                                    _parsed == null
                                        ? ''
                                        : const JsonEncoder.withIndent(
                                            '  ',
                                          ).convert(_parsed),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.format_align_center),
                          label: const Text('Beautify'),
                          onPressed: _parseAndShowError,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          onPressed: () => _copyFormatted(minified: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    // 기존 PC 레이아웃 (Row - 입력/결과 패널)
    const double cardPadding = 32;
    const double cardRadius = 18;

    return Row(
      children: [
        // 좌측 입력
        Expanded(
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(cardPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              elevation: 3,
              color: const Color(0xFFF9F3F4),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file, size: 22),
                          label: const Text(
                            'Open JSON file',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _pickFile,
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.paste, size: 22),
                          label: const Text(
                            'Paste from clipboard',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _pasteFromClipboard,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Input (JSON)',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocus,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '{ "hello": "world" }',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onTap: _updateCursorPos,
                        onChanged: (_) => _updateCursorPos(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Line $_currentLine, Col $_currentColumn',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 우측 결과
        Expanded(
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(cardPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              elevation: 3,
              color: const Color(0xFFF4E8EC),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy, size: 20),
                          label: const Text('Copy minified'),
                          onPressed: () => _copyFormatted(minified: true),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy_all, size: 20),
                          label: const Text('Copy pretty JSON'),
                          onPressed: () => _copyFormatted(minified: false),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 0),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.account_tree),
                            text: "Tree View",
                          ),
                          Tab(icon: Icon(Icons.code), text: "Text View"),
                        ],
                        indicatorColor: Colors.indigo,
                        labelColor: Colors.indigo,
                        unselectedLabelColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildTreeWithTooltip(context),
                                Scrollbar(
                                  thumbVisibility: true,
                                  interactive: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: SelectableText(
                                        _parsed == null
                                            ? ''
                                            : const JsonEncoder.withIndent(
                                                '  ',
                                              ).convert(_parsed),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: "Expand all",
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              minimumSize: const Size(34, 34),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => setState(() => _expandAll = true),
                            child: const Icon(
                              Icons.unfold_more,
                              size: 20,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Tooltip(
                          message: "Collapse all",
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              minimumSize: const Size(34, 34),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => setState(() => _expandAll = false),
                            child: const Icon(
                              Icons.unfold_less,
                              size: 20,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreeWithTooltip(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Scrollbar(
              controller: _treeHController,
              thumbVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _treeHController,
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: Scrollbar(
                    controller: _treeVController,
                    thumbVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _treeVController,
                      scrollDirection: Axis.vertical,
                      child: JsonTreeView(
                        _parsed,
                        expandAll: _expandAll,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 툴팁 (Shift+휠, 터치패드 안내)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 35,
              child: MouseRegion(
                onEnter: (_) {
                  if (!_showTooltip) {
                    setState(() => _showTooltip = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _showTooltip = false);
                    });
                  }
                },
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    opacity: _showTooltip ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade400.withOpacity(0.93),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Horizontal scroll: Shift + mouse wheel or swipe touchpad",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---- JsonTreeView, JsonExpandable, JsonLeaf ----
class JsonTreeView extends StatelessWidget {
  final dynamic data;
  final int depth;
  final bool expandAll;

  const JsonTreeView(
    this.data, {
    super.key,
    this.depth = 0,
    this.expandAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildTree(context, data, depth, expandAll);
  }

  Widget _buildTree(
    BuildContext context,
    dynamic node,
    int depth,
    bool expandAll,
  ) {
    if (node is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.entries.map((e) {
          final isComplex = e.value is Map || e.value is List;
          return Padding(
            padding: EdgeInsets.only(left: depth * 1.0, top: 1, bottom: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\"${e.key}\"',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(': '),
                if (isComplex)
                  JsonExpandable(
                    e.value,
                    depth: depth + 1,
                    expandAll: expandAll,
                  )
                else
                  JsonLeaf(e.value),
              ],
            ),
          );
        }).toList(),
      );
    } else if (node is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.asMap().entries.map((e) {
          final idx = e.key;
          final v = e.value;
          final isComplex = v is Map || v is List;
          return Padding(
            padding: EdgeInsets.only(left: depth * 1.0, top: 1, bottom: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[$idx]', style: const TextStyle(color: Colors.teal)),
                const Text(': '),
                if (isComplex)
                  JsonExpandable(v, depth: depth + 1, expandAll: expandAll)
                else
                  JsonLeaf(v),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return JsonLeaf(node);
    }
  }
}

class JsonExpandable extends StatefulWidget {
  final dynamic value;
  final int depth;
  final bool expandAll;

  const JsonExpandable(
    this.value, {
    super.key,
    this.depth = 1,
    this.expandAll = false,
  });

  @override
  State<JsonExpandable> createState() => _JsonExpandableState();
}

class _JsonExpandableState extends State<JsonExpandable> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.expandAll;
  }

  @override
  void didUpdateWidget(covariant JsonExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandAll != oldWidget.expandAll) {
      setState(() => _open = widget.expandAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMap = widget.value is Map;
    final len = isMap
        ? (widget.value as Map).length
        : (widget.value as List).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Icon(
                  _open ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 20,
                  color: Colors.indigo,
                ),
                Text(
                  isMap ? '{...} ($len)' : '[...] ($len)',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: JsonTreeView(
              widget.value,
              depth: widget.depth,
              expandAll: widget.expandAll,
            ),
          ),
      ],
    );
  }
}

class JsonLeaf extends StatelessWidget {
  final dynamic value;

  const JsonLeaf(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    String text;
    TextStyle style = const TextStyle();
    if (value == null) {
      text = 'null';
      style = const TextStyle(color: Colors.grey);
    } else if (value is String) {
      text = '"$value"';
      style = const TextStyle(color: Colors.green);
    } else if (value is num) {
      text = value.toString();
      style = const TextStyle(color: Colors.blue);
    } else if (value is bool) {
      text = value.toString();
      style = const TextStyle(color: Colors.indigo);
    } else {
      text = value.toString();
    }
    return SelectableText(
      text,
      style: style,
      maxLines: 1,
      enableInteractiveSelection: true,
    );
  }
}
