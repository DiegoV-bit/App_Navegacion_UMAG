import 'dart:math';
import '../models/grafo.dart';

/// Implementación del algoritmo A* (A-Estrella) para búsqueda de caminos óptimos.
///
/// A* es un algoritmo de búsqueda informada que encuentra el camino más corto
/// entre un nodo origen y un nodo destino en un grafo.
///
/// Características:
/// - Usa una función heurística (distancia euclidiana) para guiar la búsqueda
/// - Garantiza encontrar el camino óptimo si la heurística es admisible
/// - Más eficiente que Dijkstra al explorar menos nodos
/// - Función de evaluación: f(n) = g(n) + h(n)
///   - g(n): costo real desde el origen hasta n
///   - h(n): estimación heurística desde n hasta el destino
///
/// Ejemplo de uso:
/// ```dart
/// final astar = AStar(grafo);
/// final ruta = astar.calcular(
///   origen: 'P1_Entrada_1',
///   destino: 'P1_Sala_101',
/// );
/// ```
class AStar {
  /// Grafo sobre el cual se realizará la búsqueda de caminos.
  final Grafo grafo;

  /// Constructor que requiere un grafo.
  ///
  /// Parámetros:
  /// - [grafo]: El grafo que contiene los nodos y conexiones para la búsqueda
  AStar(this.grafo);

  /// Método de instancia que calcula la ruta óptima entre dos nodos.
  ///
  /// Este método delega en la implementación estática [calcularRuta].
  ///
  /// Parámetros:
  /// - [origen]: ID del nodo de inicio (ejemplo: "P1_Entrada_1")
  /// - [destino]: ID del nodo de destino (ejemplo: "P1_Sala_101")
  ///
  /// Retorna:
  /// - Lista de IDs de nodos que forman el camino óptimo desde origen a destino
  /// - Lista vacía si no existe camino entre los nodos
  List<String> calcular({
    required String origen,
    required String destino,
  }) {
    return AStar.calcularRuta(grafo: grafo, origen: origen, destino: destino);
  }

  /// Método estático que implementa el algoritmo A* completo.
  ///
  /// Este método mantiene compatibilidad con el uso estático anterior.
  ///
  /// Algoritmo:
  /// 1. Inicializa estructuras de datos (gScore, fScore, prev)
  /// 2. Establece el nodo origen con gScore=0 y fScore=heurística
  /// 3. Mientras haya nodos abiertos:
  ///    - Selecciona el nodo con menor fScore
  ///    - Si es el destino, reconstruye y retorna la ruta
  ///    - Para cada vecino, calcula nuevo gScore tentativo
  ///    - Si es mejor, actualiza gScore, fScore y predecessor
  /// 4. Si no encuentra camino, retorna lista vacía
  ///
  /// Parámetros:
  /// - [grafo]: El grafo que contiene los nodos y conexiones
  /// - [origen]: ID del nodo de inicio
  /// - [destino]: ID del nodo de destino
  ///
  /// Retorna:
  /// - Lista ordenada de IDs de nodos desde origen hasta destino
  /// - Lista vacía si no existe camino
  static List<String> calcularRuta({
    required Grafo grafo,
    required String origen,
    required String destino,
  }) {
    final mapa = grafo.generarMapaAdyacencia();
    final nodos = grafo.nodos;

    // Convertir lista de nodos a un mapa rápido para acceso O(1)
    final nodosMap = {for (var n in nodos) n.id: n};

    // gScore: costo real desde el origen hasta cada nodo
    final gScore = <String, double>{};

    // fScore: costo estimado total (g + h) desde origen hasta destino pasando por el nodo
    final fScore = <String, double>{};

    // prev: mapa de predecesores para reconstruir el camino
    final prev = <String, String?>{};

    // Inicializar todos los nodos con costos infinitos
    for (var n in mapa.keys) {
      gScore[n] = double.infinity;
      fScore[n] = double.infinity;
      prev[n] = null;
    }

    // Configurar el nodo de origen
    gScore[origen] = 0;
    fScore[origen] = _heuristica(
      nodosMap[origen]!,
      nodosMap[destino]!,
    );

    // Conjunto de nodos por explorar
    final abiertos = <String>{origen};

    while (abiertos.isNotEmpty) {
      // Seleccionar nodo con menor fScore (el más prometedor)
      final actual = abiertos.reduce(
        (a, b) => fScore[a]! < fScore[b]! ? a : b,
      );

      // Si llegamos al destino, reconstruir y retornar el camino
      if (actual == destino) {
        return _reconstruir(prev, destino);
      }

      // Remover el nodo actual de los abiertos
      abiertos.remove(actual);

      // Explorar todos los vecinos del nodo actual
      for (var vecino in mapa[actual]!.keys) {
        // Calcular costo tentativo para llegar al vecino
        final tentativeG = gScore[actual]! + mapa[actual]![vecino]!;

        // Si encontramos un camino mejor hacia el vecino
        if (tentativeG < gScore[vecino]!) {
          // Actualizar predecessor
          prev[vecino] = actual;

          // Actualizar gScore (costo real)
          gScore[vecino] = tentativeG;

          // Actualizar fScore (costo real + heurística)
          fScore[vecino] =
              tentativeG + _heuristica(nodosMap[vecino]!, nodosMap[destino]!);

          // Agregar vecino a los nodos por explorar
          abiertos.add(vecino);
        }
      }
    }

    // No se encontró camino
    return [];
  }

  /// Calcula la distancia heurística euclidiana entre dos nodos.
  ///
  /// La heurística es admisible (nunca sobreestima el costo real) porque
  /// la distancia en línea recta es siempre menor o igual que cualquier
  /// camino que siga las conexiones del grafo.
  ///
  /// Fórmula: √((x₂ - x₁)² + (y₂ - y₁)²)
  ///
  /// Parámetros:
  /// - [n1]: Primer nodo
  /// - [n2]: Segundo nodo
  ///
  /// Retorna:
  /// - Distancia euclidiana entre los dos nodos
  static double _heuristica(n1, n2) {
    final dx = n1.x - n2.x;
    final dy = n1.y - n2.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Reconstruye el camino desde el nodo origen hasta el destino.
  ///
  /// Utiliza el mapa de predecesores [prev] para retroceder desde el
  /// destino hasta el origen, construyendo la lista de nodos del camino.
  ///
  /// Parámetros:
  /// - [prev]: Mapa de predecesores (cada nodo apunta a su nodo anterior en el camino)
  /// - [destino]: ID del nodo de destino
  ///
  /// Retorna:
  /// - Lista ordenada de IDs de nodos desde origen hasta destino
  static List<String> _reconstruir(Map<String, String?> prev, String destino) {
    final ruta = <String>[];
    var actual = destino;

    // Retroceder desde el destino hasta el origen
    while (prev[actual] != null) {
      ruta.insert(0, actual);
      actual = prev[actual]!;
    }

    // Agregar el nodo origen al inicio
    ruta.insert(0, actual);
    return ruta;
  }
}
