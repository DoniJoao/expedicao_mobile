import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';

import '../models/pedidos.dart';

class RegistrarColetaScreen extends StatefulWidget {
  final Pedido pedido;

  const RegistrarColetaScreen({super.key, required this.pedido});

  @override
  State<RegistrarColetaScreen> createState() => _RegistrarColetaScreenState();
}

class _RegistrarColetaScreenState extends State<RegistrarColetaScreen> {
  final _nomeController = TextEditingController();
  final _documentoController = TextEditingController();
  final _placaController = TextEditingController();

  late final SignatureController _signatureController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    // Escuta mudanças pra atualizar o botão de confirmar (habilitar/desabilitar)
    _signatureController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _placaController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final nome = _nomeController.text.trim();
    final documento = _documentoController.text.trim();
    final placa = _placaController.text.trim().toUpperCase();

    final erros = <String>[];
    if (nome.isEmpty) erros.add('Informe o nome do retirante.');
    if (documento.isEmpty) erros.add('Informe o documento.');
    if (placa.isEmpty) erros.add('Informe a placa do veículo.');
    if (placa.isNotEmpty && !RegExp(r'^[A-Za-z0-9]{7}$').hasMatch(placa)) {
      erros.add('A placa deve ter 7 caracteres alfanuméricos (ex: ABC1D23).');
    }
    if (_signatureController.isEmpty) {
      erros.add('A assinatura é obrigatória. Peça para o retirante assinar.');
    }

    if (erros.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erros.first),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      // 1. Exporta o canvas como PNG
      final Uint8List? bytes = await _signatureController.toPngBytes();

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Falha ao gerar a imagem da assinatura.');
      }

      // 2. Converte pra base64 no formato data URI
      final base64Str = 'data:image/png;base64,${base64Encode(bytes)}';

      // 3. Monta o payload
      final payload = {
        'pedido_id': widget.pedido.id,
        'nome': nome,
        'documento': documento,
        'placa_veiculo': placa,
        'assinatura': base64Str,
      };

      // 4. Envia pro PHP
      final url = Uri.parse('http://localhost/expedicao_db/registrar_coleta.php');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final resultado = json.decode(utf8.decode(response.bodyBytes));

        if (resultado['sucesso'] == true) {
          // Sucesso! Mostra SnackBar verde e devolve true pra lista recarregar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['mensagem'] ?? 'Coleta registrada!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          _exibirErroServidor(
              resultado['mensagem'] ?? 'Erro desconhecido no servidor.');
        }
      } else {
        _exibirErroServidor(
            'Falha na comunicação. Código HTTP: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _exibirErroServidor('Não foi possível conectar ao servidor: $e');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _exibirErroServidor(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erro ao Registrar Coleta'),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Coleta — Pedido #${widget.pedido.numeroPedido}'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Corpo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -------- Cabeçalho resumido --------
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.pedido.cliente,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Volumes: ${widget.pedido.volumesFinais}'),
                        Text('Transportadora: ${widget.pedido.transportadora}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -------- Nome --------
                  TextField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome do retirante *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- Documento (só números) --------
                  TextField(
                    controller: _documentoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Documento (somente números) *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- Placa --------
                  TextField(
                    controller: _placaController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 7,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Placa do veículo *',
                      hintText: 'ABC1D23',
                      prefixIcon: Icon(Icons.directions_car_outlined),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // -------- Canvas de assinatura --------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assinatura do retirante *',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _signatureController.isEmpty
                            ? null
                            : () => _signatureController.clear(),
                        icon: const Icon(Icons.cleaning_services, size: 18),
                        label: const Text('LIMPAR'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Signature(
                        controller: _signatureController,
                        height: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------- Rodapé fixo --------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.teal),
                    label: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _salvando ? null : _confirmar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      _salvando ? 'PROCESSANDO...' : 'CONFIRMAR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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