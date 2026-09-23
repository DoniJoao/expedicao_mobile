import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pedidos.dart';
import '../models/coleta.dart';
import '../widgets/card_pedido.dart';

class ColetaScreen extends StatefulWidget {
  const ColetaScreen({super.key});

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coletas'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Aguardando Retirada', icon: Icon(Icons.hourglass_empty)),
            Tab(text: 'Coletas Realizadas', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AbaAguardando(),
          _AbaRealizadas(),
        ],
      ),
    );
  }
}

// =====================================================
// Aba 1: Aguardando Retirada
// =====================================================
class _AbaAguardando extends StatefulWidget {
  const _AbaAguardando();

  @override
  State<_AbaAguardando> createState() => _AbaAguardandoState();
}

class _AbaAguardandoState extends State<_AbaAguardando> {
  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erroMensagem;

  @override
  void initState() {
    super.initState();
    buscar();
  }

  Future<void> buscar() async {
    final url = Uri.parse('http://localhost/expedicao_db/listar_coletas.php');

    try {
      setState(() {
        carregando = true;
        erroMensagem = null;
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dados =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          pedidos = dados.map((j) => Pedido.fromJson(j)).toList();
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
        erroMensagem = 'Não foi possível conectar à API.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }
    if (erroMensagem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(erroMensagem!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: buscar, child: const Text('Tentar Novamente')),
          ],
        ),
      );
    }
    if (pedidos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum pedido aguardando retirada.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: buscar,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          return CardPedido(
            pedido: pedidos[index],
            onPedidoSalvo: buscar,
            modoColeta: true,
          );
        },
      ),
    );
  }
}

// =====================================================
// Aba 2: Coletas Realizadas
// =====================================================
class _AbaRealizadas extends StatefulWidget {
  const _AbaRealizadas();

  @override
  State<_AbaRealizadas> createState() => _AbaRealizadasState();
}

class _AbaRealizadasState extends State<_AbaRealizadas> {
  List<Coleta> coletas = [];
  bool carregando = true;
  String? erroMensagem;

  @override
  void initState() {
    super.initState();
    buscar();
  }

  Future<void> buscar() async {
    final url = Uri.parse(
        'http://localhost/expedicao_db/listar_coletas_feitas.php');

    try {
      setState(() {
        carregando = true;
        erroMensagem = null;
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dados =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          coletas = dados.map((j) => Coleta.fromJson(j)).toList();
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
        erroMensagem = 'Não foi possível conectar à API.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }
    if (erroMensagem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(erroMensagem!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: buscar, child: const Text('Tentar Novamente')),
          ],
        ),
      );
    }
    if (coletas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma coleta registrada.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: buscar,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: coletas.length,
        itemBuilder: (context, index) {
          final c = coletas[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.teal),
              title: Text(
                c.cliente,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Pedido #${c.pedidoId} • ${c.volumesFinais} volumes'),
                  Text('Retirado por: ${c.nome}'),
                  if (c.documento != null && c.documento!.isNotEmpty)
                    Text('Doc: ${c.documento}'),
                  if (c.placaVeiculo != null && c.placaVeiculo!.isNotEmpty)
                    Text('Placa: ${c.placaVeiculo}'),
                  Text(
                    'Data: ${c.createdAt}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () => _abrirAssinatura(c),
            ),
          );
        },
      ),
    );
  }

  void _abrirAssinatura(Coleta coleta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assinatura — Pedido #${coleta.pedidoId}'),
        content: SizedBox(
          width: 400,
          height: 250,
          child: FutureBuilder<String?>(
            future: _buscarAssinatura(coleta.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final base64Str = snapshot.data;
              if (base64Str == null || base64Str.isEmpty) {
                return const Center(
                  child: Text('Sem assinatura registrada.'),
                );
              }
              // Remove o prefixo "data:image/png;base64,"
              final limpo = base64Str.contains(',')
                  ? base64Str.split(',').last
                  : base64Str;
              return Image.memory(
                base64Decode(limpo),
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  Future<String?> _buscarAssinatura(int coletaId) async {
    final url = Uri.parse(
        'http://localhost/expedicao_db/obter_assinatura.php?id=$coletaId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['sucesso'] == true) return data['assinatura'];
      }
    } catch (_) {}
    return null;
  }
}