import 'package:flutter/material.dart';
import '../models/pedido_model.dart';

class CardPedido extends StatelessWidget {
  final Pedido pedido;

  const CardPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5EE), // seashell
        border: Border.all(color: Colors.teal, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do Cliente
          Row(
            children: [
              // Aqui entraria a imagem da empresa de forma dinâmica, ex: Image.network(...)
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
          
          // Dados do pedido
          Text('Pedido: ${pedido.numeroPedido}  |  Data: ${pedido.data}  |  Valor: R\$ ${pedido.valor.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          
          // Faixa da Transportadora (Equivalente à classe .truck)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4),
            color: Colors.teal,
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Text('Transp: ${pedido.transportadora}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 8),
          
          // Listagem dos itens do pedido
          Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...pedido.itens.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text('${item.qtd}x  [${item.um}]  - ${item.descricao}'),
          )).toList(),
          
          // Botão de instrução (Abre o Modal)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.list, color: Colors.teal),
              onPressed: () {
                // Função para chamar o modal equivalente ao seu call_instrucao()
                _mostrarModalInstrucoes(context, pedido);
              },
            ),
          )
        ],
      ),
    );
  }

  void _mostrarModalInstrucoes(BuildContext context, Pedido pedido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instruções de Faturamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pedido ID: ${pedido.id}', style: TextStyle(color: Colors.purple)),
              SizedBox(height: 10),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Adicionar Instruções de Faturamento',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                // Aqui você faria o POST via HTTP para salvar a instrução
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}