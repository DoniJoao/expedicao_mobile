import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    // Validação básica
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarErro('Preencha e-mail e senha.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ATENÇÃO: 
    // Se estiver testando no Windows Desktop/Web, use 'localhost' ou '127.0.0.1'.
    // Se estiver usando o Emulador Android, troque para '10.0.2.2'.
    const String apiUrl = 'http://localhost/expedicao_db/login.php';

    try {
      final response = await http.post(
        ApiConfig.endpoint('login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'senha': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true) {
          final funcao = data['usuario']['funcao'];
          
          // Redireciona para a rota baseada na função retornada pelo banco
          switch (funcao) {
            case 'administrador':
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case 'vendedor':
              Navigator.pushReplacementNamed(context, '/vendas');
              break;
            case 'expedicao':
              Navigator.pushReplacementNamed(context, '/expedicao');
              break;
            case 'motorista':
              Navigator.pushReplacementNamed(context, '/entregas');
              break;
            default:
              _mostrarErro('Perfil de usuário não reconhecido.');
          }
        } else {
          _mostrarErro(data['mensagem']);
        }
      } else {
        // Trata retornos como 401 (Não autorizado) ou 500 (Erro no servidor)
        final data = jsonDecode(response.body);
        _mostrarErro(data['mensagem'] ?? 'Erro no servidor.');
      }
    } catch (e) {
      _mostrarErro('Erro de conexão com o servidor. Verifique o WAMP.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  size: 100,
                  color: Colors.teal,
                ),
                const SizedBox(height: 32),
                Text(
                  'Bem-vindo de volta!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _fazerLogin,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}