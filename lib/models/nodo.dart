class Nodo {
  final String id; // Ejemplo: "P1_A101"
  final double x; // Coordenada X en el mapa SVG
  final double y; // Coordenada Y en el mapa SVG

  Nodo({
    required this.id,
    required this.x,
    required this.y,
  });

  // Conversión desde JSON
  factory Nodo.fromJson(Map<String, dynamic> json) {
    return Nodo(
      id: json['id'] as String,
      // Aceptar int o double en JSON convirtiendo desde num
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
      };
}
