import 'nodo.dart';
import 'grafo.dart';

/// Tipo de conexión vertical entre pisos
enum TipoConexionVertical {
  escalera,
  ascensor,
}

/// Representa una conexión entre diferentes pisos
class ConexionVertical {
  final String nodoOrigen; // Ejemplo: "P1_Escalera_Norte"
  final String nodoDestino; // Ejemplo: "P2_Escalera_Norte"
  final int pisoOrigen;
  final int pisoDestino;
  final TipoConexionVertical tipo;
  final double costo; // Costo de cambiar de piso (simulado)

  const ConexionVertical({
    required this.nodoOrigen,
    required this.nodoDestino,
    required this.pisoOrigen,
    required this.pisoDestino,
    required this.tipo,
    this.costo = 50.0, // Costo base de subir/bajar un piso
  });

  factory ConexionVertical.fromJson(Map<String, dynamic> json) {
    return ConexionVertical(
      nodoOrigen: json['nodoOrigen'] as String,
      nodoDestino: json['nodoDestino'] as String,
      pisoOrigen: json['pisoOrigen'] as int,
      pisoDestino: json['pisoDestino'] as int,
      tipo: TipoConexionVertical.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoConexionVertical.escalera,
      ),
      costo: (json['costo'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nodoOrigen': nodoOrigen,
        'nodoDestino': nodoDestino,
        'pisoOrigen': pisoOrigen,
        'pisoDestino': pisoDestino,
        'tipo': tipo.name,
        'costo': costo,
      };
}

/// Grafo que unifica todos los pisos del edificio
class GrafoMultiPiso {
  final Map<int, Grafo> grafosPorPiso; // {1: Grafo_P1, 2: Grafo_P2, ...}
  final List<ConexionVertical> conexionesVerticales;

  const GrafoMultiPiso({
    required this.grafosPorPiso,
    required this.conexionesVerticales,
  });

  /// Obtiene todos los nodos de todos los pisos
  List<Nodo> get todosLosNodos {
    final nodos = <Nodo>[];
    for (var grafo in grafosPorPiso.values) {
      nodos.addAll(grafo.nodos);
    }
    return nodos;
  }

  /// Busca un nodo por su ID en todos los pisos
  Nodo? buscarNodo(String id) {
    for (var grafo in grafosPorPiso.values) {
      final nodo = grafo.getNodo(id);
      if (nodo != null) return nodo;
    }
    return null;
  }

  /// Obtiene el piso de un nodo dado su ID
  int? obtenerPisoDeNodo(String nodoId) {
    for (var entry in grafosPorPiso.entries) {
      if (entry.value.getNodo(nodoId) != null) {
        return entry.key;
      }
    }
    return null;
  }

  /// Genera mapa de adyacencia multi-piso
  Map<String, Map<String, double>> generarMapaAdyacenciaMultiPiso() {
    final mapa = <String, Map<String, double>>{};

    // Agregar conexiones horizontales (dentro de cada piso)
    for (var grafo in grafosPorPiso.values) {
      final mapaHorizontal = grafo.generarMapaAdyacencia();
      for (var entry in mapaHorizontal.entries) {
        mapa[entry.key] = {...?mapa[entry.key], ...entry.value};
      }
    }

    // Agregar conexiones verticales (entre pisos)
    for (var conexion in conexionesVerticales) {
      mapa.putIfAbsent(conexion.nodoOrigen, () => {});
      mapa.putIfAbsent(conexion.nodoDestino, () => {});

      mapa[conexion.nodoOrigen]![conexion.nodoDestino] = conexion.costo;
      mapa[conexion.nodoDestino]![conexion.nodoOrigen] = conexion.costo;
    }

    return mapa;
  }

  factory GrafoMultiPiso.fromJson(Map<String, dynamic> json) {
    final pisos = <int, Grafo>{};

    // Cargar grafos de cada piso
    final grafosJson = json['pisos'] as Map<String, dynamic>;
    for (var entry in grafosJson.entries) {
      final numeroPiso = int.parse(entry.key);
      pisos[numeroPiso] = Grafo.fromJson(entry.value);
    }

    // Cargar conexiones verticales
    final conexionesJson = json['conexionesVerticales'] as List;
    final conexiones =
        conexionesJson.map((c) => ConexionVertical.fromJson(c)).toList();

    return GrafoMultiPiso(
      grafosPorPiso: pisos,
      conexionesVerticales: conexiones,
    );
  }
}
