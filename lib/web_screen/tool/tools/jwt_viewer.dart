import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 클립보드 사용
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/util/utils.dart';
import '../share/master_screen.dart';

class JwtViewerScreen extends HookConsumerWidget {
  static String routeName = "jwt-decoder";

  const JwtViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HeysTool.setMetaTags(
      title: 'JWT Decoder & Validator – heys.dev',
      description:
          'Decode, verify, and inspect JWT (JSON Web Tokens) online. Free and secure JWT debugger/validator with signature verification, pretty-print, and instant payload/header inspection.',
      imageUrl: 'https://heys.dev/assets/images/meta_jwtdecoder.png',
      // JWT 툴용 대표이미지 경로!
      url: 'https://heys.dev/jwt-decoder',
      keywords:
          'jwt decoder, jwt validator, jwt online, dev tools, json web token, heys.dev, jwt verify, jwt inspect',
      siteName: 'heys.dev',
      ogType: 'website',
      twitterCard: 'summary_large_image',
    );
    return MasterScreen(child: JwtViewerHome());
  }
}

class JwtViewerHome extends StatefulWidget {
  const JwtViewerHome({super.key});

  @override
  State<JwtViewerHome> createState() => _JwtViewerHomeState();
}

class _JwtViewerHomeState extends State<JwtViewerHome> {
  final _jwtController = TextEditingController();
  final _secretController = TextEditingController();
  String? _headerJson;
  String? _payloadJson;
  String? _verifyResult;
  Color _verifyColor = Colors.grey.shade300;

  @override
  void dispose() {
    _jwtController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _decodeAndVerify() {
    final jwtText = _jwtController.text.trim();
    final secret = _secretController.text;
    setState(() {
      _headerJson = null;
      _payloadJson = null;
      _verifyResult = null;
      _verifyColor = Colors.grey.shade300;
    });

    if (jwtText.isEmpty) return;

    try {
      final parts = jwtText.split('.');
      if (parts.length != 3) throw Exception('Invalid JWT format');
      final header = json.decode(
        utf8.decode(base64Url.decode(_normalize(parts[0]))),
      );
      final payload = json.decode(
        utf8.decode(base64Url.decode(_normalize(parts[1]))),
      );
      setState(() {
        _headerJson = _prettyJson(header);
        _payloadJson = _prettyJson(payload);
      });

      if (secret.isNotEmpty) {
        try {
          final jwt = JWT.verify(jwtText, SecretKey(secret));
          setState(() {
            _verifyResult = "Valid JWT\nSignature Verified";
            _verifyColor = Colors.green.shade100;
          });
        } catch (e) {
          setState(() {
            _verifyResult = "Invalid signature: ${e.toString()}";
            _verifyColor = Colors.red.shade100;
          });
        }
      } else {
        setState(() {
          _verifyResult = "No signature verification (secret is empty)";
          _verifyColor = Colors.grey.shade100;
        });
      }
    } catch (e) {
      setState(() {
        _headerJson = null;
        _payloadJson = null;
        _verifyResult = "Invalid JWT: ${e.toString()}";
        _verifyColor = Colors.red.shade100;
      });
    }
  }

  String _prettyJson(dynamic value) {
    var encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  String _normalize(String input) {
    // base64 패딩 보정
    return input + List.filled((4 - input.length % 4) % 4, '=').join();
  }

  // 클립보드 붙여넣기
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      setState(() {
        _jwtController.text = data.text!;
      });
      _decodeAndVerify();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty!')),
      );
    }
  }

  // 클립보드 복사
  void _copyToClipboard(String? text) {
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7EAF0), width: 1.1),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JWT 입력 + 붙여넣기 버튼
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jwtController,
                  decoration: const InputDecoration(
                    labelText: 'JWT Token',
                    hintText: 'eyJhbGciOi... (your.jwt.token)',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) => _decodeAndVerify(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.paste),
                label: const Text('Paste'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Secret 입력
          TextField(
            controller: _secretController,
            decoration: const InputDecoration(
              labelText: 'Secret (for signature verification)',
              hintText: 'a-string-secret-at-least-256-bits-long',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _decodeAndVerify(),
          ),
          const SizedBox(height: 16),
          // 검증 결과
          if (_verifyResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _verifyColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _verifyResult!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // 헤더
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: boxDecoration,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'HEADER',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: "Copy Header",
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: _headerJson == null
                                      ? null
                                      : () => _copyToClipboard(_headerJson),
                                ),
                              ],
                            ),
                            const Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  _headerJson ?? 'No header',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
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
                const SizedBox(width: 12),
                // 페이로드
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: boxDecoration,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'PAYLOAD',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: "Copy Payload",
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: _payloadJson == null
                                      ? null
                                      : () => _copyToClipboard(_payloadJson),
                                ),
                              ],
                            ),
                            const Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  _payloadJson ?? 'No payload',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
