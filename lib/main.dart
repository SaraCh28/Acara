import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/env_config.dart';
import 'core/widgets/error_boundary.dart';
import 'services/app_preferences_service.dart';

class SecureAuthStorage extends LocalStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  Future<String?> getItem(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> setItem(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> removeItem(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> hasItem(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  @override
  Future<bool> hasAccessToken() async {
    return await hasItem('supabase.auth.token');
  }

  @override
  Future<String?> accessToken() async {
    return await getItem('supabase.auth.token');
  }

  @override
  Future<void> removePersistedSession() async {
    await removeItem('supabase.auth.token');
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await setItem('supabase.auth.token', persistSessionString);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureAuthStorage(),
    ),
  );

  runApp(
    const ProviderScope(
      child: GlobalErrorBoundary(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(appPreferencesProvider);
    
    return MaterialApp.router(
      title: 'Acara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
