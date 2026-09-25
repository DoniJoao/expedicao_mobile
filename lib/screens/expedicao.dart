import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/pedidos.dart';
import '../widgets/card_pedido.dart';
import 'coleta.dart';

class ExpedicaoScreen extends StatefulWidget {
  const ExpedicaoScreen({super.key});

  @override
  _ExpedicaoScreenState createState() => _ExpedicaoScreenState();
}

class _ExpedicaoScreenState extends State<ExpedicaoScreen> {
  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erroMensagem;

  @override
  void initState() {
    super.initState();
    buscarPedidosDoBanco();
  }

  Future<void> buscarPedidosDoBanco() async {
    final url = ApiConfig.endpoint('listar_pedidos.php');

    try {
      setState(() {
        carregando = true;
        erroMensagem = null;
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dadosJson =
            json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          pedidos = dadosJson.map((json) => Pedido.fromJson(json)).toList();
          carregando = false;
        });
      } else {
        setState(() {
          erroMensagem = 'Erro no servidor: ${response.statusCode}';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erroMensagem = 'Não foi possível conectar à API. Verifique a rede.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expedição Desktop', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: buscarPedidosDoBanco,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Em separação na expedição (${pedidos.length})',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ColetaScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.draw, color: Colors.white),
              label: const Text(
                'Ir para Assinaturas de Coleta',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          Expanded(
            child: _construirCorpoTela(),
          ),
        ],
      ),
    );
  }

  Widget _construirCorpoTela() {
    if (carregando) {
      return Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (erroMensagem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text(erroMensagem!, style: TextStyle(color: Colors.red)),
            TextButton(
                onPressed: buscarPedidosDoBanco,
                child: Text('Tentar Novamente'))
          ],
        ),
      );
    }

    if (pedidos.isEmpty) {
      return Center(
        child: Text(
          'Parabéns!\nVocê concluiu a separação de todos os pedidos',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        return CardPedido(
          pedido: pedidos[index],
          onPedidoSalvo: buscarPedidosDoBanco,
        );
      },
    );
  }
}