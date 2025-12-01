import 'dart:math';
import '../models/grafo.dart';

class AStar {
  // Permitir uso instanciable manteniendo la API estática
  final Grafo grafo;

  AStar(this.grafo);

  /// Método de instancia: delega en la implementación estática
  List<String> calcular({
    required String origen,
    required String destino,
  }) {
    return AStar.calcularRuta(grafo: grafo, origen: origen, destino: destino);
  }

  /// API estática original (mantenerla para compatibilidad)
  static List<String> calcularRuta({
    required Grafo grafo,
    required String origen,
    required String destino,
  }) {
    final mapa = grafo.generarMapaAdyacencia();
    final nodos = grafo.nodos;

    // Convertir lista de nodos a un mapa rápido
    final nodosMap = {for (var n in nodos) n.id: n};

    // f = g + h
    final gScore = <String, double>{};
    final fScore = <String, double>{};
    final prev = <String, String?>{};

    for (var n in mapa.keys) {
      gScore[n] = double.infinity;
      fScore[n] = double.infinity;
      prev[n] = null;
    }

    gScore[origen] = 0;
    fScore[origen] = _heuristica(
      nodosMap[origen]!,
      nodosMap[destino]!,
    );

    final abiertos = <String>{origen};

    while (abiertos.isNotEmpty) {
      // Seleccionar nodo con menor fScore
      final actual = abiertos.reduce(
        (a, b) => fScore[a]! < fScore[b]! ? a : b,
      );

      if (actual == destino) {
        return _reconstruir(prev, destino);
      }

      abiertos.remove(actual);

      for (var vecino in mapa[actual]!.keys) {
        final tentativeG = gScore[actual]! + mapa[actual]![vecino]!;

        if (tentativeG < gScore[vecino]!) {
          prev[vecino] = actual;
          gScore[vecino] = tentativeG;
          fScore[vecino] =
              tentativeG + _heuristica(nodosMap[vecino]!, nodosMap[destino]!);

          abiertos.add(vecino);
        }
      }
    }

    return [];
  }

  // Heurística euclidiana
  static double _heuristica(n1, n2) {
    final dx = n1.x - n2.x;
    final dy = n1.y - n2.y;
    return sqrt(dx * dx + dy * dy);
  }

  static List<String> _reconstruir(Map<String, String?> prev, String destino) {
    final ruta = <String>[];
    var actual = destino;

    while (prev[actual] != null) {
      ruta.insert(0, actual);
      actual = prev[actual]!;
    }

    ruta.insert(0, actual);
    return ruta;
  }
}
