import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env.dart';
import 'core/services/crash_reporting_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: Env.supabaseAnonKey,
  );

  await CrashReportingService.instance.init();

  runZonedGuarded(() {
    runApp(const ProviderScope(child: MyVaultApp()));
  }, (error, stack) {
    CrashReportingService.instance.recordNonFatal(error, stack);
  });
}
