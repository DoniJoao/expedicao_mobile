class Pedido {
  final int id;
  final String numeroPedido;
  final String cliente;
  final String transportadora;
  final String data;
  final int volumesFinais;
  final String? observacao;
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.cliente,
    required this.transportadora,
    required this.data,
    required this.volumesFinais,
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
  final int qtd;
  final String? lote;         // lote original sugerido pelo pedido (opcional)
  final String? localizacao;
  final List<LoteDisponivel> lotesDisponiveis;

  ItemPedido({
    required this.codigo,
    required this.descricao,
    required this.qtd,
    this.lote,
    this.localizacao,
    required this.lotesDisponiveis,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    // Lê a lista nova de lotes disponíveis (com saldo)
    List<LoteDisponivel> lotes = [];
    if (json['lotes_disponiveis'] is List) {
      lotes = (json['lotes_disponiveis'] as List)
          .map((l) => LoteDisponivel.fromJson(l))
          .toList();
    } else if (json['lote'] != null && json['lote'].toString().isNotEmpty) {
      // Fallback: se por algum motivo só vier o lote antigo, cria 1 lote sem saldo
      lotes = [LoteDisponivel(lote: json['lote'].toString(), saldo: 0)];
    }

    return ItemPedido(
      codigo: json['codigo'] ?? '',
      descricao: json['nome'] ?? 'Produto sem nome',
      qtd: json['qtd_solicitada'] is int
          ? json['qtd_solicitada']
          : int.tryParse(json['qtd_solicitada'].toString()) ?? 0,
      lote: json['lote'],
      localizacao: json['localizacao'],
      lotesDisponiveis: lotes,
    );
  }
}

class LoteDisponivel {
  final String lote;
  final int saldo;

  LoteDisponivel({required this.lote, required this.saldo});

  factory LoteDisponivel.fromJson(Map<String, dynamic> json) {
    return LoteDisponivel(
      lote: json['lote']?.toString() ?? '',
      saldo: json['saldo'] is int
          ? json['saldo']
          : int.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
    );
  }
}