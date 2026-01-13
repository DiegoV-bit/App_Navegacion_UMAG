/// Representa una conexión (arista) entre dos nodos en el grafo de navegación.
///
/// Una conexión define que existe un camino transitable entre dos puntos del edificio.
/// Las conexiones pueden ser bidireccionales (se puede ir en ambas direcciones).
///
/// Cada conexión contiene:
/// - [origen]: ID del nodo de inicio
/// - [destino]: ID del nodo de llegada
/// - [distancia]: Distancia entre los nodos (en unidades del mapa SVG)
class Conexion {
  /// ID del nodo de origen (ejemplo: "P1_Entrada_1")
  final String origen;

  /// ID del nodo de destino (ejemplo: "P1_Pasillo_01")
  final String destino;

  /// Distancia entre los dos nodos en unidades del mapa SVG.
  /// Esta distancia se usa para calcular rutas óptimas con el algoritmo A*.
  final double distancia;

  /// Constructor de la conexión.
  ///
  /// Parámetros requeridos:
  /// - [origen]: ID del nodo desde donde inicia la conexión
  /// - [destino]: ID del nodo donde termina la conexión
  /// - [distancia]: Distancia entre ambos nodos
  Conexion({
    required this.origen,
    required this.destino,
    required this.distancia,
  });

  /// Crea una instancia de [Conexion] desde un objeto JSON.
  ///
  /// El JSON debe tener la estructura:
  /// ```json
  /// {
  ///   "origen": "P1_Entrada_1",
  ///   "destino": "P1_Pasillo_01",
  ///   "distancia": 50.0,
  ///   "bidireccional": true
  /// }
  /// ```
  ///
  /// Acepta valores int o double para distancia, convirtiéndolos a double.
  factory Conexion.fromJson(Map<String, dynamic> json) {
    return Conexion(
      origen: json['origen'] as String,
      destino: json['destino'] as String,
      // Aceptar int o double en JSON convirtiendo desde num
      distancia: (json['distancia'] as num).toDouble(),
    );
  }

  /// Convierte la conexión a un objeto JSON.
  ///
  /// Retorna un Map con la estructura:
  /// ```dart
  /// {
  ///   'origen': 'P1_Entrada_1',
  ///   'destino': 'P1_Pasillo_01',
  ///   'distancia': 50.0
  /// }
  /// ```
  Map<String, dynamic> toJson() => {
        'origen': origen,
        'destino': destino,
        'distancia': distancia,
      };
}
