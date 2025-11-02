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
      origen: json['origen'],
      destino: json['destino'],
      distancia: json['distancia'],
    );
  }

  Map<String, dynamic> toJson() => {
        'origen': origen,
        'destino': destino,
        'distancia': distancia,
      };
}
