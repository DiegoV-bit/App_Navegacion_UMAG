import 'nodo.dart';
import 'conexion.dart';

class Grafo {
  final List<Nodo> nodos;
  final List<Conexion> conexiones;

  Grafo({required this.nodos, required this.conexiones});

  // Cargar grafo desde JSON
  factory Grafo.fromJson(Map<String, dynamic> json) {
    var nodosList = (json['nodos'] as List)
        .map((nodoJson) => Nodo.fromJson(nodoJson))
        .toList();

    var conexionesList = (json['conexiones'] as List)
        .map((conJson) => Conexion.fromJson(conJson))
        .toList();

    return Grafo(nodos: nodosList, conexiones: conexionesList);
  }

  // Buscar un nodo por ID
  Nodo? getNodo(String id) {
    try {
      return nodos.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Crear mapa de adyacencia (para Dijkstra)
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
