import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> mainLoad(WidgetsBinding widgetsBinding) async {
  await Supabase.initialize(
    url: 'https://hlskzjtcivwyixxaynpl.supabase.co',
    anonKey: 'sb_publishable_vVNmybp22sZAxPkghJvoZQ__h3GgxKv', // 바로 이 키!
  );
}
