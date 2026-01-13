import 'nodo.dart';
import 'conexion.dart';

/// Representa el grafo completo de navegación de un piso del edificio.
///
/// Un grafo es una estructura de datos que modela la red de caminos transitables
/// dentro del edificio. Está compuesto por:
/// - [nodos]: Lista de puntos de interés y ubicaciones en el piso
/// - [conexiones]: Lista de caminos que conectan los nodos entre sí
///
/// El grafo se utiliza para:
/// 1. Almacenar la topología del edificio
/// 2. Calcular rutas óptimas usando el algoritmo A*
/// 3. Navegar entre diferentes ubicaciones del mismo piso

class Grafo {
  /// Lista de todos los nodos (ubicaciones) del grafo.
  /// Cada nodo representa un punto específico en el mapa del piso.
  final List<Nodo> nodos;

  /// Lista de todas las conexiones (aristas) del grafo.
  /// Cada conexión representa un camino transitable entre dos nodos.
  final List<Conexion> conexiones;

  /// Constructor del grafo.
  ///
  /// Parámetros requeridos:
  /// - [nodos]: Lista de nodos que conforman el grafo
  /// - [conexiones]: Lista de conexiones entre los nodos
  Grafo({required this.nodos, required this.conexiones});

  /// Crea una instancia de [Grafo] desde un objeto JSON.
  ///
  /// El JSON debe tener la estructura:
  /// ```json
  /// {
  ///   "nodos": [
  ///     {"id": "P1_Entrada_1", "x": 600.0, "y": 750.0},
  ///     {"id": "P1_Pasillo_01", "x": 650.0, "y": 750.0}
  ///   ],
  ///   "conexiones": [
  ///     {"origen": "P1_Entrada_1", "destino": "P1_Pasillo_01", "distancia": 50.0}
  ///   ]
  /// }
  /// ```
  ///
  /// Este método se usa para cargar los grafos desde los archivos JSON
  /// ubicados en `lib/data/grafo_piso{1-4}.json`.
  
  factory Grafo.fromJson(Map<String, dynamic> json) {
    var nodosList = (json['nodos'] as List)
        .map((nodoJson) => Nodo.fromJson(nodoJson))
        .toList();

    var conexionesList = (json['conexiones'] as List)
        .map((conJson) => Conexion.fromJson(conJson))
        .toList();

    return Grafo(nodos: nodosList, conexiones: conexionesList);
  }

  /// Busca y retorna un nodo por su ID.
  ///
  /// Parámetros:
  /// - [id]: ID del nodo a buscar (ejemplo: "P1_Entrada_1")
  ///
  /// Retorna:
  /// - El nodo encontrado si existe
  /// - `null` si no se encuentra ningún nodo con ese ID
  ///
  /// Ejemplo:
  /// ```dart
  /// final nodo = grafo.getNodo('P1_Entrada_1');
  /// if (nodo != null) {
  ///   print('Nodo encontrado en (${nodo.x}, ${nodo.y})');
  /// }
  /// ```
  
  Nodo? getNodo(String id) {
    try {
      return nodos.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Genera un mapa de adyacencia del grafo para algoritmos de búsqueda de rutas.
  ///
  /// El mapa de adyacencia es una estructura de datos que facilita encontrar
  /// los nodos vecinos de cualquier nodo dado y la distancia hacia ellos.
  ///
  /// Retorna un Map con la estructura:
  /// ```dart
  /// {
  ///   'P1_Entrada_1': {
  ///     'P1_Pasillo_01': 50.0,
  ///     'P1_Pasillo_02': 45.0
  ///   },
  ///   'P1_Pasillo_01': {
  ///     'P1_Entrada_1': 50.0,
  ///     'P1_Sala_101': 30.0
  ///   }
  /// }
  /// ```
  ///
  /// Nota: Las conexiones se crean como bidireccionales automáticamente,
  /// es decir, si hay una conexión de A a B, también se crea de B a A
  /// con la misma distancia.
  ///
  /// Este mapa se utiliza internamente por el algoritmo A* para
  /// calcular rutas óptimas.
  
  Map<String, Map<String, double>> generarMapaAdyacencia() {
    final mapa = <String, Map<String, double>>{};
    for (var c in conexiones) {
      mapa.putIfAbsent(c.origen, () => {});
      mapa.putIfAbsent(c.destino, () => {});
      mapa[c.origen]![c.destino] = c.distancia;
      mapa[c.destino]![c.origen] = c.distancia; // conexión bidireccional
    }
    return mapa;
  }
}
