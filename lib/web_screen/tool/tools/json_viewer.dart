import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class JsonViewerScreen extends HookConsumerWidget {
  static String routeName = "json-viewer";

  const JsonViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: JsonViewerHome(),
    );
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
        _error = "⚠️ JSON 파싱 오류: $msg";
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
        SnackBar(content: Text(minified ? 'Minified 복사!' : '포매팅 복사!')),
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

  @override
  Widget build(BuildContext context) {
    const double cardPadding = 32;
    const double cardRadius = 18;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Viewer / Formatter'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F3F4),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Row(
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
                                    icon: const Icon(
                                      Icons.upload_file,
                                      size: 22,
                                    ),
                                    label: const Text(
                                      'JSON 파일 열기',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 11,
                                      ),
                                      backgroundColor: Colors.indigo.shade500,
                                      foregroundColor: Colors.white,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _pickFile,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '입력 (JSON)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
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
                                    hintText: '{ \"hello\": \"world\" }',
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
                                    label: const Text('Minified 복사'),
                                    onPressed: () =>
                                        _copyFormatted(minified: true),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.copy_all, size: 20),
                                    label: const Text('포매팅 복사'),
                                    onPressed: () =>
                                        _copyFormatted(minified: false),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 0,
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.account_tree),
                                      text: "트리 뷰",
                                    ),
                                    Tab(icon: Icon(Icons.code), text: "텍스트 뷰"),
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
                                        children: [
                                          // ── 트리뷰 탭 ──
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Tooltip(
                                                    message: "모두 펼치기",
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                7,
                                                              ),
                                                        ),
                                                        minimumSize: Size(
                                                          34,
                                                          34,
                                                        ),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      onPressed: () => setState(
                                                        () => _expandAll = true,
                                                      ),
                                                      child: Icon(
                                                        Icons.unfold_more,
                                                        size: 20,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Tooltip(
                                                    message: "모두 접기",
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                7,
                                                              ),
                                                        ),
                                                        minimumSize: Size(
                                                          34,
                                                          34,
                                                        ),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      onPressed: () => setState(
                                                        () =>
                                                            _expandAll = false,
                                                      ),
                                                      child: Icon(
                                                        Icons.unfold_less,
                                                        size: 20,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                              ),
                                              Expanded(
                                                child: Scrollbar(
                                                  thumbVisibility: true,
                                                  child: SingleChildScrollView(
                                                    child: _parsed == null
                                                        ? const Center(
                                                            child: Text(
                                                              '유효한 JSON을 입력하세요',
                                                            ),
                                                          )
                                                        : JsonTreeView(
                                                            _parsed,
                                                            expandAll:
                                                                _expandAll,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // ── 텍스트 뷰 탭 ──
                                          Scrollbar(
                                            thumbVisibility: true,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Beautify 버튼 화면 중앙 플로팅
              IgnorePointer(
                ignoring: false,
                child: Align(
                  alignment: Alignment.center,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hovered = true),
                    onExit: (_) => setState(() => _hovered = false),
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      transform: Matrix4.translationValues(
                        0,
                        _hovered ? -8 : 0,
                        0,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (_hovered)
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                        ],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: FilledButton.icon(
                        icon: const Icon(Icons.format_align_center, size: 25),
                        label: const Text(
                          'Beautify',
                          style: TextStyle(fontSize: 20),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(130, 64),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: _hovered ? 6 : 2,
                        ),
                        onPressed: _parseAndShowError,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ───────── 트리 뷰/Leaf/Expandable
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
            padding: EdgeInsets.only(left: depth * 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\"${e.key}\"',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(': '),
                if (isComplex)
                  Expanded(
                    child: JsonExpandable(
                      e.value,
                      depth: depth + 1,
                      expandAll: expandAll,
                    ),
                  )
                else
                  Flexible(child: JsonLeaf(e.value)), // <-- Flexible!
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
            padding: EdgeInsets.only(left: depth * 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[$idx]', style: TextStyle(color: Colors.teal)),
                const Text(': '),
                if (isComplex)
                  Expanded(
                    child: JsonExpandable(
                      v,
                      depth: depth + 1,
                      expandAll: expandAll,
                    ),
                  )
                else
                  Flexible(child: JsonLeaf(v)), // <-- Flexible!
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
      setState(() {
        _open = widget.expandAll;
      });
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
                  style: TextStyle(
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
            padding: const EdgeInsets.only(left: 16),
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
    // **Flexible + overflow/softWrap 옵션!**
    return Text(
      text,
      style: style,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
    );
  }
}
