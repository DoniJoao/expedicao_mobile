import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../screens/pedido.dart';
import '../screens/registrar_coleta.dart';

class CardPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onPedidoSalvo;
  final bool modoColeta;

  const CardPedido({
    super.key,
    required this.pedido,
    this.onPedidoSalvo,
    this.modoColeta = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _aoClicar(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5EE),
          border: Border.all(color: Colors.teal, width: 1),
          borderRadius: BorderRadius.circular(4),
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
                    pedido.cliente,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido: ${pedido.numeroPedido}  |  Data: ${pedido.data}  |  Volumes: ${pedido.volumesFinais}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              color: Colors.teal,
              child: Row(
                children: [
                  const Icon(Icons.local_shipping,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Transp: ${pedido.transportadora}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                border: Border.all(color: Colors.purple[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment,
                          color: Colors.purple[700], size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Instruções de Faturamento:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedido.observacao ??
                        'Nenhuma instrução cadastrada para este pedido.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple[900],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Itens:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ...pedido.itens.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '${item.qtd}x  - ${item.descricao}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                )),
            if (modoColeta) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _registrarColeta(context),
                  icon: const Icon(Icons.assignment_turned_in,
                      color: Colors.white),
                  label: const Text(
                    'REGISTRAR COLETA',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _aoClicar(BuildContext context) {
    if (modoColeta) return; // Em modo coleta, só o botão age
    _abrirPedido(context);
  }

  Future<void> _abrirPedido(BuildContext context) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PedidoScreen(pedido: pedido),
      ),
    );
    if (resultado == true) {
      onPedidoSalvo?.call();
    }
  }
  Future<void> _registrarColeta(BuildContext context) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => RegistrarColetaScreen(pedido: pedido),
      ),
    );

    // Se a tela de registro devolveu true, avisa a lista pra recarregar
    if (resultado == true) {
      onPedidoSalvo?.call();
    }
  }
}