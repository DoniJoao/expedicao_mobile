import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../screens/pedido.dart';

class CardPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onPedidoSalvo;

  const CardPedido({
    super.key,
    required this.pedido,
    this.onPedidoSalvo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final resultado = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => PedidoScreen(pedido: pedido),
          ),
        );

        // Se a PedidoScreen devolveu true, avisa a tela pai pra recarregar
        if (resultado == true) {
          onPedidoSalvo?.call();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFFF5EE),
          border: Border.all(color: Colors.teal, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pedido.cliente,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            Text(
              'Pedido: ${pedido.numeroPedido}  |  Data: ${pedido.data}  |  Volumes: ${pedido.volumesFinais}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(6),
              color: Colors.teal,
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Transp: ${pedido.transportadora}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
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
                      SizedBox(width: 4),
                      Text(
                        'Instruções de Faturamento:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
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
            SizedBox(height: 8),

            Text('Itens:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ...pedido.itens.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '${item.qtd}x  - ${item.descricao}',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}