class Coleta {
  final int id;
  final int pedidoId;
  final String cliente;
  final String transportadora;
  final int volumesFinais;
  final String nome;
  final String? documento;
  final String? placaVeiculo;
  final int assinaturaTamanho;  // tamanho em bytes (não o base64)
  final String createdAt;

  Coleta({
    required this.id,
    required this.pedidoId,
    required this.cliente,
    required this.transportadora,
    required this.volumesFinais,
    required this.nome,
    this.documento,
    this.placaVeiculo,
    required this.assinaturaTamanho,
    required this.createdAt,
  });

  factory Coleta.fromJson(Map<String, dynamic> json) {
    return Coleta(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      pedidoId: json['pedido_id'] is int
          ? json['pedido_id']
          : int.tryParse(json['pedido_id'].toString()) ?? 0,
      cliente: json['cliente'] ?? 'Cliente removido',
      transportadora: json['transportadora'] ?? 'Padrão',
      volumesFinais: json['volumes_finais'] is int
          ? json['volumes_finais']
          : int.tryParse(json['volumes_finais'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      documento: json['documento'],
      placaVeiculo: json['placa_veiculo'],
      assinaturaTamanho: json['assinatura_tamanho'] is int
          ? json['assinatura_tamanho']
          : int.tryParse(json['assinatura_tamanho'].toString()) ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}