import 'package:flutter/material.dart';
import '../models/pedido_model.dart';
import '../widgets/card_pedido.dart';

class ExpedicaoScreen extends StatefulWidget {
  @override
  _ExpedicaoScreenState createState() => _ExpedicaoScreenState();
}

class _ExpedicaoScreenState extends State<ExpedicaoScreen> {
  // Simulando sua lista de pedidos (substituiria pelo retorno do seu PHP/API)
  List<Pedido> pedidos = [
    Pedido(
      id: "2662",
      empresa: "sf",
      cliente: "VENTOLUFY VENTILAÇÃO E SERVIÇOS MARITIMOS",
      numeroPedido: "26/00777",
      data: "19/05/2026",
      valor: 300.00,
      transportadora: "ENTREGA",
      itens: [ItemPedido(qtd: 1, um: "PC", descricao: "EXAUSTOR EQ870M3 127V")],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expedição Desktop', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Header com a contagem (Semelhante ao seu .secao do CSS)
          Container(
            width: double.infinity,
            color: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Em separação na expedição (${pedidos.length})',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          
          // Corpo dinâmico (Vazio ou com Itens)
          Expanded(
            child: pedidos.isEmpty
                ? Center(
                    child: Text(
                      'Parabéns!\nVocê concluiu a separação de todos os pedidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      return CardPedido(pedido: pedidos[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}