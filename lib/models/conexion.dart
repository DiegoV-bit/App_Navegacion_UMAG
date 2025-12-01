class Conexion {
  final String origen;
  final String destino;
  final double distancia;

  Conexion({
    required this.origen,
    required this.destino,
    required this.distancia,
  });

  factory Conexion.fromJson(Map<String, dynamic> json) {
    return Conexion(
      origen: json['origen'] as String,
      destino: json['destino'] as String,
      // Aceptar int o double en JSON convirtiendo desde num
      distancia: (json['distancia'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'origen': origen,
        'destino': destino,
        'distancia': distancia,
      };
}
