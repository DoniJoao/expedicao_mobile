import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/expedicao.dart';
import 'screens/coleta.dart';
import 'screens/placeholder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Logístico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login':     (context) => const LoginScreen(),
        '/expedicao': (context) => const ExpedicaoScreen(),
        '/coletas':   (context) => const ColetaScreen(),
        '/admin':     (context) => const PlaceholderScreen(titulo: 'Painel Admin'),
        '/vendas':    (context) => const PlaceholderScreen(titulo: 'Vendas'),
        '/entregas':  (context) => const PlaceholderScreen(titulo: 'Entregas'),
      },
    );
  }
}