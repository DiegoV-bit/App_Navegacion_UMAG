import 'dart:math';
import '../models/nodo.dart';
import '../models/grafo_multipiso.dart';

/// Resultado del cálculo de ruta multi-piso
class ResultadoRutaMultiPiso {
  final List<String> ruta;
  final double distanciaTotal;
  final Map<int, List<String>> rutaPorPiso; // {1: [nodos_P1], 2: [nodos_P2]}
  final List<String> puntosTransicion; // Nodos donde se cambia de piso

  const ResultadoRutaMultiPiso({
    required this.ruta,
    required this.distanciaTotal,
    required this.rutaPorPiso,
    required this.puntosTransicion,
  });
}

/// Implementación de A* para navegación multi-piso
class AStarMultiPiso {
  final GrafoMultiPiso grafoMultiPiso;

  AStarMultiPiso(this.grafoMultiPiso);

  /// Calcula la ruta óptima entre dos nodos, incluso si están en pisos diferentes
  ResultadoRutaMultiPiso? calcularRuta({
    required String origen,
    required String destino,
  }) {
    final nodoOrigen = grafoMultiPiso.buscarNodo(origen);
    final nodoDestino = grafoMultiPiso.buscarNodo(destino);

    if (nodoOrigen == null || nodoDestino == null) {
      return null;
    }

    final mapaAdyacencia = grafoMultiPiso.generarMapaAdyacenciaMultiPiso();

    // Estructuras para A*
    final abiertos = PriorityQueue<_NodoA>((a, b) => a.f.compareTo(b.f));
    final cerrados = <String>{};
    final costoG = <String, double>{origen: 0.0};
    final padres = <String, String>{};

    abiertos.add(_NodoA(
      id: origen,
      g: 0.0,
      h: _calcularHeuristica(nodoOrigen, nodoDestino),
    ));

    while (abiertos.isNotEmpty) {
      final actual = abiertos.removeFirst();

      if (actual.id == destino) {
        // Reconstruir ruta
        return _reconstruirRuta(
          origen: origen,
          destino: destino,
          padres: padres,
          costoG: costoG,
        );
      }

      cerrados.add(actual.id);

      final vecinos = mapaAdyacencia[actual.id] ?? {};
      for (var vecino in vecinos.entries) {
        if (cerrados.contains(vecino.key)) continue;

        final costoTentativoG = costoG[actual.id]! + vecino.value;

        if (!costoG.containsKey(vecino.key) ||
            costoTentativoG < costoG[vecino.key]!) {
          padres[vecino.key] = actual.id;
          costoG[vecino.key] = costoTentativoG;

          final nodoVecino = grafoMultiPiso.buscarNodo(vecino.key);
          if (nodoVecino != null) {
            final h = _calcularHeuristica(nodoVecino, nodoDestino);
            abiertos.add(_NodoA(
              id: vecino.key,
              g: costoTentativoG,
              h: h,
            ));
          }
        }
      }
    }

    return null; // No se encontró ruta
  }

  /// Calcula la heurística euclidiana entre dos nodos
  double _calcularHeuristica(Nodo actual, Nodo destino) {
    // Si están en diferentes pisos, agregar penalización
    final pisoActual = grafoMultiPiso.obtenerPisoDeNodo(actual.id);
    final pisoDestino = grafoMultiPiso.obtenerPisoDeNodo(destino.id);

    final dx = actual.x - destino.x;
    final dy = actual.y - destino.y;
    final distanciaEuclidiana = sqrt(dx * dx + dy * dy);

    // Agregar costo estimado de cambio de piso
    final diferenciasPiso = (pisoActual! - pisoDestino!).abs();
    final costoVertical = diferenciasPiso * 40.0; // Costo estimado por piso

    return distanciaEuclidiana + costoVertical;
  }

  /// Reconstruye la ruta desde el mapa de padres
  ResultadoRutaMultiPiso _reconstruirRuta({
    required String origen,
    required String destino,
    required Map<String, String> padres,
    required Map<String, double> costoG,
  }) {
    final ruta = <String>[];
    String? actual = destino;

    while (actual != null) {
      ruta.insert(0, actual);
      actual = padres[actual];
    }

    // Organizar ruta por piso
    final rutaPorPiso = <int, List<String>>{};
    final puntosTransicion = <String>[];

    int? pisoAnterior;
    for (var nodoId in ruta) {
      final piso = grafoMultiPiso.obtenerPisoDeNodo(nodoId);
      if (piso != null) {
        rutaPorPiso.putIfAbsent(piso, () => []).add(nodoId);

        if (pisoAnterior != null && piso != pisoAnterior) {
          puntosTransicion.add(nodoId);
        }
        pisoAnterior = piso;
      }
    }

    return ResultadoRutaMultiPiso(
      ruta: ruta,
      distanciaTotal: costoG[destino]!,
      rutaPorPiso: rutaPorPiso,
      puntosTransicion: puntosTransicion,
    );
  }
}

/// Clase interna para representar nodos en A*
class _NodoA {
  final String id;
  final double g; // Costo desde el origen
  final double h; // Heurística al destino

  double get f => g + h; // Costo total estimado

  _NodoA({required this.id, required this.g, required this.h});
}

/// Cola de prioridad simple
class PriorityQueue<T> {
  final List<T> _items = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  void add(T item) {
    _items.add(item);
    _items.sort(_comparator);
  }

  T removeFirst() => _items.removeAt(0);

  bool get isNotEmpty => _items.isNotEmpty;
}
