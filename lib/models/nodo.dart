/// Representa un nodo en el grafo de navegación del edificio.
///
/// Un nodo es un punto específico en el mapa que puede ser:
/// - Una entrada, pasillo, intersección, esquina, puerta
/// - Un lugar de interés como laboratorios, salas, baños, etc.
///
/// Cada nodo tiene:
/// - [id]: Identificador único (formato: "P{piso}_{nombre}", ejemplo: "P1_A101")
/// - [x]: Coordenada X en el sistema de coordenadas del mapa SVG (0-1200)
/// - [y]: Coordenada Y en el sistema de coordenadas del mapa SVG (0-800)
class Nodo {
  /// Identificador único del nodo (ejemplo: "P1_A101", "P2_Lab_Fisica")
  final String id;

  /// Coordenada X en el mapa SVG (rango típico: 0-1200)
  final double x;

  /// Coordenada Y en el mapa SVG (rango típico: 0-800)
  final double y;

  /// Constructor del nodo.
  ///
  /// Requiere:
  /// - [id]: Identificador único del nodo
  /// - [x]: Posición horizontal en el mapa SVG
  /// - [y]: Posición vertical en el mapa SVG
  Nodo({
    required this.id,
    required this.x,
    required this.y,
  });

  /// Crea una instancia de [Nodo] desde un objeto JSON.
  ///
  /// El JSON debe tener la estructura:
  /// ```json
  /// {
  ///   "id": "P1_Entrada_Principal",
  ///   "x": 600.0,
  ///   "y": 750.0
  /// }
  /// ```
  ///
  /// Acepta tanto valores int como double para las coordenadas x e y,
  /// convirtiéndolos automáticamente a double.
  factory Nodo.fromJson(Map<String, dynamic> json) {
    return Nodo(
      id: json['id'] as String,
      // Aceptar int o double en JSON convirtiendo desde num
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  /// Convierte el nodo a un objeto JSON.
  ///
  /// Retorna un Map con la estructura:
  /// ```dart
  /// {
  ///   'id': 'P1_Entrada_Principal',
  ///   'x': 600.0,
  ///   'y': 750.0
  /// }
  /// ```
  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
      };
}
