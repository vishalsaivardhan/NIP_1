import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'routing/app_router.dart';

  void main() {
    runApp(const ProviderScope(child: NIPApp()));
  }

  class NIPApp extends ConsumerWidget {
    const NIPApp({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final router = AppRouter.router;
      return MaterialApp.router(
        title: 'ProxiUPI (NIP)',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: router,
      );
    }
  }
    );
