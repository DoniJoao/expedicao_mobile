import 'package:flutter/material.dart';
// Importações das futuras telas:
import 'screens/login.dart';
import 'screens/expedicao.dart'; 
import 'screens/coleta.dart';
// import 'screens/entregas.dart';

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
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      
      // O app agora sempre nasce na tela de login
      initialRoute: '/login',
      
      // Mapeamento global de rotas do aplicativo
      routes: {
        '/login': (context) => const LoginScreen(),
        '/expedicao': (context) => const ExpedicaoScreen(),
        '/coletas': (context) => const ColetaScreen()
        
        // Rotas que criaremos nos próximos passos:
        // '/admin': (context) => const AdminScreen(),
        // '/vendas': (context) => const VendasScreen(),
        // '/entregas': (context) => const EntregasScreen(),
      },
    );
  }
}