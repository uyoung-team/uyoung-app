import 'package:flutter/material.dart';

class UyoungApp extends StatelessWidget {
  const UyoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uyoung App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6B5B)),
        useMaterial3: true,
      ),
      home: const _AppEntryPage(),
    );
  }
}

class _AppEntryPage extends StatelessWidget {
  const _AppEntryPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Uyoung App'),
      ),
    );
  }
}
