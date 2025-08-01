import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/util/utils.dart';
import '../share/master_screen.dart';

class DiffCheckerPage extends HookConsumerWidget {
  static String routeName = "diff-checker";

  const DiffCheckerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HeysTool.setMetaTags(
      title: 'Diff Checker – heys.dev',
      description:
          'Compare two code files. Highlight differences and navigate easily using the minimap.',
      url: 'https://heys.dev/diff-checker',
      keywords:
          'diff checker, code compare, minimap, winmerge, vscode, heys.dev',
      siteName: 'heys.dev',
      ogType: 'website',
      twitterCard: 'summary_large_image',
    );
    return MasterScreen(child: const DiffCheckerHome());
  }
}

class DiffCheckerHome extends StatefulWidget {
  const DiffCheckerHome({super.key});

  @override
  State<DiffCheckerHome> createState() => _DiffCheckerHomeState();
}

class _DiffCheckerHomeState extends State<DiffCheckerHome> {
  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  final _leftScroll = ScrollController();
  final _rightScroll = ScrollController();
  List<_LineDiff> _leftLines = [];
  List<_LineDiff> _rightLines = [];
  List<int> _diffLineIndexes = [];
  bool _ignoreWhitespace = false;

  void _compare() {
    final left = _leftController.text;
    final right = _rightController.text;
    final leftSplit = left.split('\n');
    final rightSplit = right.split('\n');
    final maxLen = leftSplit.length > rightSplit.length
        ? leftSplit.length
        : rightSplit.length;

    final leftDiffs = <_LineDiff>[];
    final rightDiffs = <_LineDiff>[];
    final diffIndexes = <int>[];

    for (int i = 0; i < maxLen; i++) {
      final l = i < leftSplit.length ? leftSplit[i] : '';
      final r = i < rightSplit.length ? rightSplit[i] : '';
      DiffType ltype = DiffType.equal, rtype = DiffType.equal;
      if (_ignoreWhitespace ? l.trim() != r.trim() : l != r) {
        if (l.isNotEmpty && r.isNotEmpty) {
          ltype = DiffType.modify;
          rtype = DiffType.modify;
        } else if (l.isNotEmpty) {
          ltype = DiffType.delete;
        } else if (r.isNotEmpty) {
          rtype = DiffType.insert;
        }
        diffIndexes.add(i);
      }
      leftDiffs.add(_LineDiff(line: l, type: ltype, index: i));
      rightDiffs.add(_LineDiff(line: r, type: rtype, index: i));
    }
    setState(() {
      _leftLines = leftDiffs;
      _rightLines = rightDiffs;
      _diffLineIndexes = diffIndexes;
    });
  }

  void _reset() {
    _leftController.clear();
    _rightController.clear();
    setState(() {
      _leftLines = [];
      _rightLines = [];
      _diffLineIndexes = [];
    });
  }

  void _swap() {
    final left = _leftController.text;
    final right = _rightController.text;
    _leftController.text = right;
    _rightController.text = left;
    _compare();
  }

  void _jumpToLine(int idx) {
    const double lineHeight = 24;
    final pos = (idx - 2).clamp(0, 10000) * lineHeight;
    _leftScroll.animateTo(
      pos,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
    _rightScroll.animateTo(
      pos,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _leftScroll.dispose();
    _rightScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 820;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diff Checker',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InputBox(
                    controller: _leftController,
                    label: 'Source',
                    onChanged: (_) => _compare(),
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 18, height: isMobile ? 16 : 0),
                Expanded(
                  child: _InputBox(
                    controller: _rightController,
                    label: 'Target',
                    onChanged: (_) => _compare(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Swap'),
                  onPressed: _swap,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _ignoreWhitespace,
                      onChanged: (v) => setState(() {
                        _ignoreWhitespace = v ?? false;
                        _compare();
                      }),
                    ),
                    const Text("Ignore whitespace"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: DiffCodeBox(
                    lines: _leftLines,
                    scroll: _leftScroll,
                    side: DiffSide.left,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 6,
                  child: DiffCodeBox(
                    lines: _rightLines,
                    scroll: _rightScroll,
                    side: DiffSide.right,
                  ),
                ),
                const SizedBox(width: 12),
                DiffMiniMap(
                  lineCount: _leftLines.length,
                  diffIndexes: _diffLineIndexes,
                  onTap: _jumpToLine,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum DiffType { equal, insert, delete, modify }

enum DiffSide { left, right }

class _LineDiff {
  final String line;
  final DiffType type;
  final int index;

  _LineDiff({required this.line, required this.type, required this.index});
}

class DiffCodeBox extends StatelessWidget {
  final List<_LineDiff> lines;
  final ScrollController scroll;
  final DiffSide side;

  const DiffCodeBox({
    required this.lines,
    required this.scroll,
    required this.side,
    super.key,
  });

  Color? _bgForType(DiffType type) {
    switch (type) {
      case DiffType.insert:
        return Colors.yellow[200];
      case DiffType.delete:
        return Colors.orange[200];
      case DiffType.modify:
        return Colors.red[100];
      default:
        return null;
    }
  }

  Color? _textForType(DiffType type) {
    switch (type) {
      case DiffType.insert:
        return Colors.orange[900];
      case DiffType.delete:
        return Colors.red[800];
      case DiffType.modify:
        return Colors.deepOrange;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double lineHeight = 24;
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: lines.isEmpty
          ? Center(
              child: Text(
                "Diff result will be shown here.",
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          : Scrollbar(
              controller: scroll,
              thumbVisibility: true,
              child: ListView.builder(
                controller: scroll,
                itemExtent: lineHeight,
                itemCount: lines.length,
                padding: const EdgeInsets.symmetric(vertical: 2),
                itemBuilder: (context, i) {
                  final line = lines[i];
                  return Container(
                    color: _bgForType(line.type),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${line.index + 1}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: SelectableText(
                            line.line,
                            style: TextStyle(
                              fontFamily: "FiraMono",
                              fontSize: 13.5,
                              color:
                                  _textForType(line.type) ??
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class DiffMiniMap extends StatelessWidget {
  final int lineCount;
  final List<int> diffIndexes;
  final void Function(int lineIdx) onTap;

  const DiffMiniMap({
    required this.lineCount,
    required this.diffIndexes,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double mapHeight = 380;
    const double markerHeight = 8;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        final y = details.localPosition.dy.clamp(0.0, mapHeight);
        int lineIdx = ((y / mapHeight) * (lineCount - 1)).round();
        onTap(lineIdx);
      },
      child: Container(
        width: 28,
        height: mapHeight,
        margin: const EdgeInsets.only(left: 6, right: 6, top: 2),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            for (final idx in diffIndexes)
              Positioned(
                top: idx * (mapHeight / (lineCount > 1 ? lineCount : 1)),
                left: 4,
                right: 4,
                height: markerHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onChanged;

  const _InputBox({
    required this.controller,
    required this.label,
    this.onChanged,
  });

  Future<void> _handlePaste(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      controller.text = data!.text!;
      if (onChanged != null) onChanged!(controller.text);
    }
  }

  Future<void> _handleUpload(BuildContext context) async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = '.txt,.json,.csv,.js,.dart,.java,.kt,.py';
    uploadInput.click();
    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsText(file);
        await reader.onLoad.first;
        final text = reader.result as String;
        controller.text = text;
        if (onChanged != null) onChanged!(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.content_paste_rounded, size: 20),
              tooltip: 'Paste from Clipboard',
              onPressed: () => _handlePaste(context),
            ),
            IconButton(
              icon: const Icon(Icons.upload_file, size: 20),
              tooltip: 'Upload from File',
              onPressed: () => _handleUpload(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            minLines: 6,
            onChanged: onChanged,
            style: const TextStyle(fontFamily: 'FiraMono', fontSize: 15),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
