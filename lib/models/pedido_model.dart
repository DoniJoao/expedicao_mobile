class Pedido {
  final String id;
  final String empresa;
  final String cliente;
  final String numeroPedido;
  final String data;
  final double valor;
  final String transportadora;
  final List<ItemPedido> itens;
  final String? observacao;

  Pedido({
    required this.id,
    required this.empresa,
    required this.cliente,
    required this.numeroPedido,
    required this.data,
    required this.valor,
    required this.transportadora,
    required this.itens,
    this.observacao,
  });
}

class ItemPedido {
  final int qtd;
  final String um;
  final String descricao;

  ItemPedido({required this.qtd, required this.um, required this.descricao});
}