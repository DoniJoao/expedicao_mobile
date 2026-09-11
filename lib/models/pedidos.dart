class Pedido {
  final int id;
  final String numeroPedido;
  final String cliente;
  final String transportadora;
  final String data;
  final int volumesFinais;
  final double valor; // <- Adicionado para corrigir a linha 51
  final String? observacao; // <- Adicionado para corrigir a linha 99
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.cliente,
    required this.transportadora,
    required this.data,
    required this.volumesFinais,
    required this.valor,
    this.observacao,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      numeroPedido: json['numero_pedido'] ?? json['id'].toString(),
      cliente: json['cliente'] ?? 'Cliente não informado',
      transportadora: json['transportadora'] ?? 'Padrão',
      data: json['data_criacao'] ?? '',
      volumesFinais: json['volumes_finais'] is int 
          ? json['volumes_finais'] 
          : int.tryParse(json['volumes_finais'].toString()) ?? 0,
      // Transforma o valor do banco em decimal (double). Se vier vazio, vira 0.0
      valor: json['valor'] != null 
          ? double.tryParse(json['valor'].toString()) ?? 0.0 
          : 0.0,
      // Puxa a observação do banco
      observacao: json['observacao'],
      itens: json['itens'] != null
          ? (json['itens'] as List).map((i) => ItemPedido.fromJson(i)).toList()
          : [],
    );
  }
}

class ItemPedido {
  final String codigo;
  final String descricao; 
  final String um;
  final int qtd; 
  final List<String> lotesDisponiveis; 
  final String? loteSelecionado; 
  final String? localizacao;

  ItemPedido({
    required this.codigo,
    required this.descricao,
    required this.um,
    required this.qtd,
    required this.lotesDisponiveis,
    this.loteSelecionado,
    this.localizacao,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    List<String> lotes = [];
    if (json['lote'] != null && json['lote'].toString().isNotEmpty) {
      lotes.add(json['lote'].toString());
    }

    return ItemPedido(
      codigo: json['codigo'] ?? '',
      descricao: json['nome'] ?? 'Produto sem nome',
      um: json['um'] ?? 'UN',
      qtd: json['qtd_solicitada'] is int 
          ? json['qtd_solicitada'] 
          : int.tryParse(json['qtd_solicitada'].toString()) ?? 0,
      lotesDisponiveis: lotes,
      loteSelecionado: json['lote'],
      localizacao: json['localizacao'],
    );
  }
}