import 'package:flutter/material.dart';
import '../config.dart';
import '../models/pedidos.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PedidoScreen extends StatefulWidget {
  final Pedido pedido;

  const PedidoScreen({super.key, required this.pedido});

  @override
  _PedidoScreenState createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _volumesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    for (var item in widget.pedido.itens) {
      for (var loteDisp in item.lotesDisponiveis) {
        final chaveUnica = '${item.codigo}_${loteDisp.lote}';
        _controllers[chaveUnica] = TextEditingController();

        // Opção C: pré-preenche SOMENTE quando há um único lote
        // e a quantidade pedida cabe no saldo dele.
        // (evita sugerir uma quantidade inválida em multi-lote)
        final bool loteUnico = item.lotesDisponiveis.length == 1;
        final bool cabeNoSaldo = item.qtd <= loteDisp.saldo;
        final bool ehLoteSugerido = item.lote == loteDisp.lote;

        if (loteUnico && cabeNoSaldo && ehLoteSugerido) {
          _controllers[chaveUnica]!.text = item.qtd.toString();
        }
      }
    }

    _volumesController.text = '1';
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _volumesController.dispose();
    super.dispose();
  }

  Future<void> _salvarConferencia() async {
    List<String> erros = [];
    List<Map<String, dynamic>> itensParaEnviar = [];

    // 1. Validação dos volumes
    final int qtdVolumes = int.tryParse(_volumesController.text) ?? 0;
    if (qtdVolumes <= 0) {
      erros.add('A quantidade de volumes do pedido deve ser maior que zero.');
    }

    // 2. Validação e montagem do payload
    for (var item in widget.pedido.itens) {
      int somaColetadaProduto = 0;

      for (var loteDisp in item.lotesDisponiveis) {
        final chaveUnica = '${item.codigo}_${loteDisp.lote}';
        final int qtdDigitada =
            int.tryParse(_controllers[chaveUnica]?.text ?? '') ?? 0;

        if (qtdDigitada > loteDisp.saldo) {
          erros.add(
              '${item.descricao} / Lote ${loteDisp.lote}: você digitou $qtdDigitada mas só há ${loteDisp.saldo} disponível.');
        }

        somaColetadaProduto += qtdDigitada;

        itensParaEnviar.add({
          "codigo": item.codigo,
          "lote": loteDisp.lote,
          "qtd_coletada": qtdDigitada,
        });
      }

      final int qtdEsperada = item.qtd;

      if (somaColetadaProduto < qtdEsperada) {
        erros.add(
            '${item.descricao}: Falta coletar ${qtdEsperada - somaColetadaProduto} un.');
      } else if (somaColetadaProduto > qtdEsperada) {
        erros.add(
            '${item.descricao}: Quantidade acima do pedido em ${somaColetadaProduto - qtdEsperada} un.');
      }
    }

    if (erros.isNotEmpty) {
      _exibirAlertaDivergencia(erros);
      return;
    }

    // --- Envio para o PHP ---
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    try {
      final url = ApiConfig.endpoint('confirmar_pedidos.php');

      final payload = {
        "pedido_id": widget.pedido.id,
        "volumes": qtdVolumes,
        "itens": itensParaEnviar,
      };

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode(payload),
          )
          .timeout(Duration(seconds: 10));

      if (!mounted) return;
      Navigator.of(context).pop(); // fecha rodinha

      if (response.statusCode == 200) {
        // CORREÇÃO: usa utf8.decode pra não quebrar com acentos
        final resultado = json.decode(utf8.decode(response.bodyBytes));

        if (resultado['sucesso'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['mensagem'] ?? 'Pedido confirmado!'),
              backgroundColor: Colors.green,
            ),
          );
          // CORREÇÃO: devolve true pra ExpedicaoScreen recarregar
          Navigator.of(context).pop(true);
        } else {
          _exibirErroServidor(resultado['mensagem'] ?? 'Erro desconhecido.');
        }
      } else {
        _exibirErroServidor(
            'Falha na comunicação. Código HTTP: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _exibirErroServidor(
          'Não foi possível conectar ao servidor da expedição.');
    }
  }

  void _exibirAlertaDivergencia(List<String> erros) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[800]),
            SizedBox(width: 10),
            Text('Atenção na Conferência'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: erros
                .map((erro) => Text('• $erro',
                    style: TextStyle(color: Colors.red[700], height: 1.4)))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('REVISAR'),
          ),
        ],
      ),
    );
  }

  void _exibirErroServidor(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erro no Processamento'),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pedido - ${widget.pedido.numeroPedido}'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Cabeçalho
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pedido.cliente,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transportadora: ${widget.pedido.transportadora}',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Data: ${widget.pedido.data}',
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Lista de itens
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: widget.pedido.itens.length,
              itemBuilder: (context, index) {
                final item = widget.pedido.itens[index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                item.descricao.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Código: ',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500)),
                                  Text(item.codigo,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Quantidade no Pedido: ',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    '${item.qtd} un',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (item.localizacao != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  'LOC: ${item.localizacao}',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),

                        Text(
                          'Distribuição por Lotes:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),

                        Column(
                          children: item.lotesDisponiveis.map<Widget>((loteDisp) {
                            final chaveUnica =
                                '${item.codigo}_${loteDisp.lote}';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Icon(Icons.layers,
                                            size: 16,
                                            color: Colors.blue[700]),
                                        SizedBox(width: 6),
                                        Text(
                                          '${loteDisp.lote}:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 40,
                                      child: TextField(
                                        controller: _controllers[chaveUnica],
                                        keyboardType:
                                            TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Max: ${loteDisp.saldo}',
                                          hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue, width: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Volumes finais
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.teal[700]),
                    SizedBox(width: 8),
                    Text(
                      'Volumes Finais da Carga:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.teal[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  height: 45,
                  child: TextField(
                    controller: _volumesController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rodapé
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: Colors.teal),
                    label: Text(
                      'VOLTAR',
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _salvarConferencia,
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      'SALVAR',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}