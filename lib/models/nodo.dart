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
      id: json['id'],
      x: json['x'],
      y: json['y'],
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
      };
}
