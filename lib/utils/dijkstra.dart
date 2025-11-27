import '../models/grafo.dart';

class Dijkstra {
  /// Calcula la ruta más corta entre [inicio] y [destino] dentro del [grafo].
  static List<String> calcularRuta(Grafo grafo, String inicio, String destino) {
    final mapa = grafo.generarMapaAdyacencia();

    final distancias = <String, double>{};
    final anteriores = <String, String?>{};
    final noVisitados = <String>{};

    // Inicializar distancias
    for (var nodo in mapa.keys) {
      distancias[nodo] = double.infinity;
      anteriores[nodo] = null;
      noVisitados.add(nodo);
    }

    distancias[inicio] = 0;

    while (noVisitados.isNotEmpty) {
      // Encontrar el nodo no visitado con menor distancia
      String nodoActual = _obtenerNodoMenorDistancia(distancias, noVisitados);

      // Si llegamos al destino, se reconstruye la ruta
      if (nodoActual == destino) break;

      noVisitados.remove(nodoActual);

      // Actualizar distancias a vecinos
      mapa[nodoActual]?.forEach((vecino, distancia) {
        final distanciaAlternativa = distancias[nodoActual]! + distancia;

        if (distanciaAlternativa < distancias[vecino]!) {
          distancias[vecino] = distanciaAlternativa;
          anteriores[vecino] = nodoActual;
        }
      });
    }

    return _reconstruirRuta(anteriores, inicio, destino);
  }

  /// Selecciona el nodo con menor distancia acumulada.
  static String _obtenerNodoMenorDistancia(
      Map<String, double> distancias, Set<String> noVisitados) {
    String menorNodo = noVisitados.first;
    double menorDistancia = distancias[menorNodo]!;

    for (var nodo in noVisitados) {
      if (distancias[nodo]! < menorDistancia) {
        menorDistancia = distancias[nodo]!;
        menorNodo = nodo;
      }
    }

    return menorNodo;
  }

  /// Reconstruye la ruta desde el destino hacia el origen.
  static List<String> _reconstruirRuta(
      Map<String, String?> anteriores, String inicio, String destino) {
    final ruta = <String>[];
    String? nodoActual = destino;

    while (nodoActual != null) {
      ruta.add(nodoActual);
      nodoActual = anteriores[nodoActual];
    }

    return ruta.reversed.toList();
  }
}
