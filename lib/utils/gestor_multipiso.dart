import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/grafo.dart';
import '../models/nodo.dart';
import 'a_estrella.dart';

/// Gestiona la navegación entre múltiples pisos del edificio
class GestorMultiPiso {
  final Map<int, Grafo> _grafosPorPiso = {};
  final List<ConexionVertical> _conexionesVerticales = [];
  bool _inicializado = false;

  /// Indica si el gestor ha sido inicializado
  bool get inicializado => _inicializado;

  /// Carga todos los pisos del edificio
  Future<void> cargarTodosLosPisos() async {
    if (_inicializado) return;

    try {
      for (int piso = 1; piso <= 4; piso++) {
        final jsonString = await rootBundle.loadString(
          'lib/data/grafo_piso$piso.json',
        );
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        _grafosPorPiso[piso] = Grafo.fromJson(jsonData);
      }

      await _identificarConexionesVerticales();
      _inicializado = true;
    } catch (e) {
      throw Exception('Error al cargar pisos: $e');
    }
  }

  /// Identifica escaleras y ascensores que conectan pisos
  Future<void> _identificarConexionesVerticales() async {
    _conexionesVerticales.clear();

    for (int piso = 1; piso <= 4; piso++) {
      final grafo = _grafosPorPiso[piso];
      if (grafo == null) continue;

      for (final nodo in grafo.nodos) {
        // Buscar nodos de escaleras y ascensores
        if (nodo.id.toLowerCase().contains('escalera') ||
            nodo.id.toLowerCase().contains('ascensor')) {
          // Intentar encontrar el nodo correspondiente en otro piso
          final nodoOtroPiso = _buscarNodoCorrespondienteOtroPiso(nodo, piso);

          if (nodoOtroPiso != null) {
            final tipo = nodo.id.toLowerCase().contains('ascensor')
                ? TipoConexionVertical.ascensor
                : TipoConexionVertical.escalera;

            _conexionesVerticales.add(
              ConexionVertical(
                nodoOrigen: nodo.id,
                pisoOrigen: piso,
                nodoDestino: nodoOtroPiso.nodoId,
                pisoDestino: nodoOtroPiso.piso,
                tipo: tipo,
                distancia: tipo == TipoConexionVertical.ascensor ? 15.0 : 25.0,
              ),
            );
          }
        }
      }
    }
  }

  /// Busca un nodo correspondiente en otro piso (misma ubicación relativa)
  _NodoOtroPiso? _buscarNodoCorrespondienteOtroPiso(Nodo nodo, int pisoActual) {
    // Buscar en pisos adyacentes
    for (int piso in [pisoActual - 1, pisoActual + 1]) {
      if (piso < 1 || piso > 4) continue;

      final grafo = _grafosPorPiso[piso];
      if (grafo == null) continue;

      // Buscar nodos con nombre similar o coordenadas cercanas
      for (final nodoOtroPiso in grafo.nodos) {
        // Comparar nombres (quitando el prefijo del piso)
        final nombreActual = nodo.id.replaceFirst('P$pisoActual', '');
        final nombreOtro = nodoOtroPiso.id.replaceFirst('P$piso', '');

        if (nombreActual == nombreOtro) {
          return _NodoOtroPiso(nodoId: nodoOtroPiso.id, piso: piso);
        }

        // Comparar coordenadas (permitir diferencia de hasta 50 unidades)
        final dx = (nodo.x - nodoOtroPiso.x).abs();
        final dy = (nodo.y - nodoOtroPiso.y).abs();

        if (dx < 50 && dy < 50) {
          final esEscaleraOAscensor =
              nodoOtroPiso.id.toLowerCase().contains('escalera') ||
                  nodoOtroPiso.id.toLowerCase().contains('ascensor');

          if (esEscaleraOAscensor) {
            return _NodoOtroPiso(nodoId: nodoOtroPiso.id, piso: piso);
          }
        }
      }
    }

    return null;
  }

  /// Calcula la ruta completa incluyendo cambios de piso si es necesario
  List<SegmentoRuta> calcularRutaMultiPiso(
    String origenId,
    int pisoOrigen,
    String destinoId,
    int pisoDestino,
  ) {
    if (!_inicializado) {
      throw Exception('El gestor no ha sido inicializado');
    }

    if (pisoOrigen == pisoDestino) {
      // Ruta en el mismo piso
      return _calcularRutaMismoPiso(origenId, destinoId, pisoOrigen);
    }

    // Ruta con cambio de piso
    return _calcularRutaConCambioPiso(
      origenId,
      pisoOrigen,
      destinoId,
      pisoDestino,
    );
  }

  /// Calcula ruta dentro del mismo piso
  List<SegmentoRuta> _calcularRutaMismoPiso(
    String origenId,
    String destinoId,
    int piso,
  ) {
    final grafo = _grafosPorPiso[piso];
    if (grafo == null) return [];

    final calculadora = AStar(grafo);
    final ruta = calculadora.calcular(origen: origenId, destino: destinoId);

    if (ruta.isEmpty) return [];

    final distancia = _calcularDistanciaRuta(grafo, ruta);

    return [
      SegmentoRuta(
        piso: piso,
        nodos: ruta,
        tipo: TipoSegmento.caminata,
        distancia: distancia,
      ),
    ];
  }

  /// Calcula ruta con cambio de piso
  List<SegmentoRuta> _calcularRutaConCambioPiso(
    String origenId,
    int pisoOrigen,
    String destinoId,
    int pisoDestino,
  ) {
    final segmentos = <SegmentoRuta>[];

    // Encontrar la mejor conexión vertical
    final mejorConexion = _encontrarMejorConexionVertical(
      origenId,
      pisoOrigen,
      destinoId,
      pisoDestino,
    );

    if (mejorConexion == null) return [];

    // Segmento 1: Origen hasta la conexión vertical en piso origen
    final grafoOrigen = _grafosPorPiso[pisoOrigen]!;
    final calculadoraOrigen = AStar(grafoOrigen);
    final rutaHastaConexion = calculadoraOrigen.calcular(
        origen: origenId, destino: mejorConexion.nodoOrigen);

    if (rutaHastaConexion.isNotEmpty) {
      segmentos.add(
        SegmentoRuta(
          piso: pisoOrigen,
          nodos: rutaHastaConexion,
          tipo: TipoSegmento.caminata,
          distancia: _calcularDistanciaRuta(grafoOrigen, rutaHastaConexion),
        ),
      );
    }

    // Segmento 2: Conexión vertical (escalera/ascensor)
    segmentos.add(
      SegmentoRuta(
        piso: pisoOrigen,
        nodos: [mejorConexion.nodoOrigen],
        tipo: mejorConexion.tipo == TipoConexionVertical.escalera
            ? TipoSegmento.escalera
            : TipoSegmento.ascensor,
        pisoDestino: mejorConexion.pisoDestino,
        distancia: mejorConexion.distancia,
        conexionVertical: mejorConexion,
      ),
    );

    // Si hay pisos intermedios, calcular ruta recursivamente
    if ((pisoDestino - mejorConexion.pisoDestino).abs() > 0) {
      final segmentosIntermedios = _calcularRutaConCambioPiso(
        mejorConexion.nodoDestino,
        mejorConexion.pisoDestino,
        destinoId,
        pisoDestino,
      );
      segmentos.addAll(segmentosIntermedios);
    } else {
      // Segmento 3: Desde conexión en piso destino hasta destino final
      final grafoDestino = _grafosPorPiso[pisoDestino]!;
      final calculadoraDestino = AStar(grafoDestino);
      final rutaDesdeConexion = calculadoraDestino.calcular(
        origen: mejorConexion.nodoDestino,
        destino: destinoId,
      );

      if (rutaDesdeConexion.isNotEmpty) {
        segmentos.add(
          SegmentoRuta(
            piso: pisoDestino,
            nodos: rutaDesdeConexion,
            tipo: TipoSegmento.caminata,
            distancia: _calcularDistanciaRuta(grafoDestino, rutaDesdeConexion),
          ),
        );
      }
    }

    return segmentos;
  }

  /// Encuentra la mejor conexión vertical considerando distancia total
  ConexionVertical? _encontrarMejorConexionVertical(
    String origenId,
    int pisoOrigen,
    String destinoId,
    int pisoDestino,
  ) {
    ConexionVertical? mejorConexion;
    double mejorDistancia = double.infinity;

    // Determinar dirección (subir o bajar)
    final direccion = pisoDestino > pisoOrigen ? 1 : -1;
    final pisoObjetivo = pisoOrigen + direccion;

    for (final conexion in _conexionesVerticales) {
      if (conexion.pisoOrigen != pisoOrigen) continue;
      if (conexion.pisoDestino != pisoObjetivo) continue;

      final grafoOrigen = _grafosPorPiso[pisoOrigen]!;
      final calculadoraOrigen = AStar(grafoOrigen);

      // Distancia desde origen hasta la conexión
      final rutaHastaConexion = calculadoraOrigen.calcular(
          origen: origenId, destino: conexion.nodoOrigen);
      if (rutaHastaConexion.isEmpty) continue;

      final distanciaHastaConexion =
          _calcularDistanciaRuta(grafoOrigen, rutaHastaConexion);

      // Estimar distancia desde conexión hasta destino
      double distanciaDesdeConexion = 0.0;

      if (pisoObjetivo == pisoDestino) {
        // Destino está en el piso inmediatamente superior/inferior
        final grafoDestino = _grafosPorPiso[pisoDestino]!;
        final calculadoraDestino = AStar(grafoDestino);
        final rutaDesdeConexion = calculadoraDestino.calcular(
          origen: conexion.nodoDestino,
          destino: destinoId,
        );
        if (rutaDesdeConexion.isEmpty) continue;
        distanciaDesdeConexion =
            _calcularDistanciaRuta(grafoDestino, rutaDesdeConexion);
      } else {
        // Hay pisos intermedios, estimar distancia
        distanciaDesdeConexion = 100.0 * (pisoDestino - pisoObjetivo).abs();
      }

      final distanciaTotal =
          distanciaHastaConexion + conexion.distancia + distanciaDesdeConexion;

      if (distanciaTotal < mejorDistancia) {
        mejorDistancia = distanciaTotal;
        mejorConexion = conexion;
      }
    }

    return mejorConexion;
  }

  /// Obtiene todas las opciones posibles de ruta
  List<OpcionRuta> obtenerOpcionesRuta(
    String origenId,
    int pisoOrigen,
    String destinoId,
    int pisoDestino,
  ) {
    final opciones = <OpcionRuta>[];

    if (pisoOrigen == pisoDestino) {
      // Solo una opción: ruta directa
      final segmentos = calcularRutaMultiPiso(
        origenId,
        pisoOrigen,
        destinoId,
        pisoDestino,
      );

      if (segmentos.isNotEmpty) {
        opciones.add(
          OpcionRuta(
            segmentos: segmentos,
            distanciaTotal: _calcularDistanciaTotal(segmentos),
            tiempoEstimado: _calcularTiempoEstimado(segmentos),
            tipo: null,
          ),
        );
      }

      return opciones;
    }

    // Buscar opciones por escalera y ascensor
    final conexionesDisponibles = <ConexionVertical>[];

    for (final conexion in _conexionesVerticales) {
      if (conexion.pisoOrigen == pisoOrigen) {
        conexionesDisponibles.add(conexion);
      }
    }

    // Agrupar por tipo
    final conexionesEscalera = conexionesDisponibles
        .where((c) => c.tipo == TipoConexionVertical.escalera)
        .toList();
    final conexionesAscensor = conexionesDisponibles
        .where((c) => c.tipo == TipoConexionVertical.ascensor)
        .toList();

    // Calcular mejor ruta por escalera
    if (conexionesEscalera.isNotEmpty) {
      final segmentos = calcularRutaMultiPiso(
        origenId,
        pisoOrigen,
        destinoId,
        pisoDestino,
      );

      if (segmentos.isNotEmpty &&
          segmentos.any((s) => s.tipo == TipoSegmento.escalera)) {
        opciones.add(
          OpcionRuta(
            segmentos: segmentos,
            distanciaTotal: _calcularDistanciaTotal(segmentos),
            tiempoEstimado: _calcularTiempoEstimado(segmentos),
            tipo: TipoConexionVertical.escalera,
          ),
        );
      }
    }

    // Calcular mejor ruta por ascensor
    if (conexionesAscensor.isNotEmpty) {
      final segmentos = calcularRutaMultiPiso(
        origenId,
        pisoOrigen,
        destinoId,
        pisoDestino,
      );

      if (segmentos.isNotEmpty &&
          segmentos.any((s) => s.tipo == TipoSegmento.ascensor)) {
        opciones.add(
          OpcionRuta(
            segmentos: segmentos,
            distanciaTotal: _calcularDistanciaTotal(segmentos),
            tiempoEstimado: _calcularTiempoEstimado(segmentos),
            tipo: TipoConexionVertical.ascensor,
          ),
        );
      }
    }

    // Ordenar por distancia
    opciones.sort((a, b) => a.distanciaTotal.compareTo(b.distanciaTotal));

    return opciones;
  }

  double _calcularDistanciaTotal(List<SegmentoRuta> segmentos) {
    return segmentos.fold(0.0, (sum, seg) => sum + seg.distancia);
  }

  /// Calcula la distancia total de una ruta en un grafo
  double _calcularDistanciaRuta(Grafo grafo, List<String> ruta) {
    if (ruta.length < 2) return 0.0;

    double distanciaTotal = 0.0;
    final mapa = grafo.generarMapaAdyacencia();

    for (int i = 0; i < ruta.length - 1; i++) {
      final origen = ruta[i];
      final destino = ruta[i + 1];

      if (mapa[origen] != null && mapa[origen]![destino] != null) {
        distanciaTotal += mapa[origen]![destino]!;
      }
    }

    return distanciaTotal;
  }

  int _calcularTiempoEstimado(List<SegmentoRuta> segmentos) {
    // Tiempo en segundos (velocidad promedio 1.4 m/s para caminar)
    return segmentos.fold(0, (sum, seg) {
      if (seg.tipo == TipoSegmento.escalera) {
        return sum + 60; // 1 minuto por escalera por piso
      }
      if (seg.tipo == TipoSegmento.ascensor) {
        return sum + 30; // 30 segundos por ascensor
      }
      return sum + (seg.distancia / 1.4).round();
    });
  }

  /// Obtiene el grafo de un piso específico
  Grafo? getGrafoPiso(int piso) => _grafosPorPiso[piso];

  /// Obtiene todas las conexiones verticales
  List<ConexionVertical> get conexionesVerticales =>
      List.unmodifiable(_conexionesVerticales);
}

// ==================== Clases auxiliares ====================

class _NodoOtroPiso {
  final String nodoId;
  final int piso;

  _NodoOtroPiso({required this.nodoId, required this.piso});
}

/// Representa una conexión vertical entre pisos
class ConexionVertical {
  final String nodoOrigen;
  final int pisoOrigen;
  final String nodoDestino;
  final int pisoDestino;
  final TipoConexionVertical tipo;
  final double distancia;

  ConexionVertical({
    required this.nodoOrigen,
    required this.pisoOrigen,
    required this.nodoDestino,
    required this.pisoDestino,
    required this.tipo,
    required this.distancia,
  });
}

enum TipoConexionVertical { escalera, ascensor }

/// Representa un segmento de la ruta (puede ser caminata, escalera o ascensor)
class SegmentoRuta {
  final int piso;
  final List<String> nodos;
  final TipoSegmento tipo;
  final int? pisoDestino;
  final double distancia;
  final ConexionVertical? conexionVertical;

  SegmentoRuta({
    required this.piso,
    required this.nodos,
    required this.tipo,
    this.pisoDestino,
    this.distancia = 0.0,
    this.conexionVertical,
  });

  String get descripcion {
    switch (tipo) {
      case TipoSegmento.caminata:
        return 'Caminar en Piso $piso';
      case TipoSegmento.escalera:
        return 'Subir/bajar por escalera al Piso $pisoDestino';
      case TipoSegmento.ascensor:
        return 'Tomar ascensor al Piso $pisoDestino';
    }
  }
}

enum TipoSegmento { caminata, escalera, ascensor }

/// Representa una opción completa de ruta
class OpcionRuta {
  final List<SegmentoRuta> segmentos;
  final double distanciaTotal;
  final int tiempoEstimado;
  final TipoConexionVertical? tipo;

  OpcionRuta({
    required this.segmentos,
    required this.distanciaTotal,
    required this.tiempoEstimado,
    this.tipo,
  });

  String get descripcion {
    if (tipo == null) return 'Ruta directa';
    return tipo == TipoConexionVertical.escalera
        ? 'Por escaleras'
        : 'Por ascensor';
  }
}
