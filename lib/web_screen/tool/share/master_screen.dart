import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MasterScreen extends HookConsumerWidget {
  final Widget child;

  const MasterScreen({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            const _Top(),
            Expanded(
              child: Row(
                children: [
                  const _Drawer(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.blue,
      child: Row(
        children: [
          Image.asset('assets/images/logo_heysdays.png', height: 50),
        ],
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.amber,
    );
  }
}
