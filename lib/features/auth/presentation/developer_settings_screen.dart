// lib/features/auth/presentation/developer_settings_screen.dart
//
// Opened by long-pressing the logo on the login screen. Lets a device
// point at a different backend URL without rebuilding the app — useful
// when a device's configured backend URL goes stale.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/dio_client.dart';
import '../application/auth_providers.dart';

class DeveloperSettingsScreen extends ConsumerStatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  ConsumerState<DeveloperSettingsScreen> createState() => _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends ConsumerState<DeveloperSettingsScreen> {
  final _urlCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = ref.read(secureStorageProvider);
    final saved = await storage.readBackendUrlOverride();
    _urlCtrl.text = saved ?? kDefaultBackendUrl;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final storage = ref.read(secureStorageProvider);
    await storage.saveBackendUrlOverride(_urlCtrl.text.trim());
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend URL saved')),
      );
    }
  }

  Future<void> _reset() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearBackendUrlOverride();
    _urlCtrl.text = kDefaultBackendUrl;
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset to default backend URL')),
      );
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Developer Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7FB4FF)))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend URL',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: kDefaultBackendUrl,
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.28)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.055),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E7BFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          ),
                          child: Text(_saving ? 'Saving…' : 'Save'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          ),
                          child: const Text('Reset to default', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
