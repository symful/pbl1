import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/writer/presentation/writer_screen.dart';
import 'features/image_editor/presentation/image_editor_screen.dart';
import 'features/video_editor/presentation/video_editor_screen.dart';


void main() {
  AppConfig.setEnvironment(Environment.dev);
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/writer',
      builder: (context, state) => const WriterScreen(),
    ),
    GoRoute(
      path: '/image-editor',
      builder: (context, state) => const ImageEditorScreen(),
    ),
    GoRoute(
      path: '/video-editor',
      builder: (context, state) => const VideoEditorScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gemini Wrapper',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
