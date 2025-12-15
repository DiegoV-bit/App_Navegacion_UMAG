import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'dart:convert';
import '../models/grafo.dart';
import '../utils/a_estrella.dart';

/// Utilidades para manejo de códigos QR en la aplicación de navegación UMAG
class QRUtils {
  // ==================== FORMATOS QR SOPORTADOS ====================
  static const List<String> formatosSoportados = [
    'nodo:', // nodo:P1_Entrada_1
    'ruta:', // ruta:P1_Entrada_1|P1_Pasillo_Ingenieria_Centro
    'piso:', // piso:1|nodo:P1_Entrada_1
    'coord:', // coord:1004,460 (coordenadas SVG)
    'ubicacion:', // ubicacion:Entrada Principal (alias)
    // Formato JSON también soportado:
    // {"type": "nodo", "id": "P1_Entrada_1", "piso": 1, "x": 100, "y": 200}
  ];

  // ==================== ALIAS DE UBICACIONES (para códigos legibles) ====================
  static final Map<String, String> aliasUbicaciones = {
    'Entrada Principal': 'P1_Entrada_1',
    'Patio de Ingeniería': 'P1_Patio_de_ingenieria',
    'Administración TI': 'P1_Administracion_TI',
    'Secretaría Computación': 'P1_Secretaria_de_Computacion',
    'Ascensor': 'P1_Ascensor',
    'Laboratorio Física': 'P1_Laboratorio_Fisica',
    'Baños Ingeniería': 'P1_Baños_ingenieria',
    'Baños Ciencias': 'P1_Baños_ciencias',
    'Sala Magister Computación': 'P1_Sala_Magister_comp',
    'Laboratorio Austro-UMAG': 'P1_Lab_Austro-UMAG',
    'Laboratorio Tesla': 'P1_Lab_Tesla',
  };

  // ==================== PARSER DE CÓDIGOS QR ====================
  static QRResult parseQRCode(String qrData, int pisoActual) {
    if (qrData.isEmpty) {
      return QRResult.error('Código QR vacío');
    }

    qrData = qrData.trim();

    // 0. Formato JSON (nuevo - generado por el script de Python)
    // Ejemplo: {"type": "nodo", "id": "P1_Entrada_1", "piso": 1, "x": 100, "y": 200}
    if (qrData.startsWith('{') && qrData.endsWith('}')) {
      try {
        final Map<String, dynamic> jsonData = json.decode(qrData);

        // Validar que tenga el campo 'type'
        if (jsonData.containsKey('type')) {
          final type = jsonData['type'] as String?;

          if (type == 'nodo') {
            final id = jsonData['id'] as String?;
            final piso = jsonData['piso'] as int?;

            if (id != null) {
              return QRResult.nodo(
                id: id,
                piso: piso ?? _extraerPisoDeId(id) ?? pisoActual,
              );
            }
          } else if (type == 'ruta') {
            final origen = jsonData['origen'] as String?;
            final destino = jsonData['destino'] as String?;

            if (origen != null && destino != null) {
              return QRResult.ruta(
                origen: origen,
                destino: destino,
                piso: jsonData['piso'] as int? ?? pisoActual,
              );
            }
          } else if (type == 'coordenadas' || type == 'coord') {
            final x = (jsonData['x'] as num?)?.toDouble();
            final y = (jsonData['y'] as num?)?.toDouble();

            if (x != null && y != null) {
              return QRResult.coordenadasSVG(
                x: x,
                y: y,
                piso: jsonData['piso'] as int? ?? pisoActual,
              );
            }
          }
        }

        return QRResult.error('Formato JSON QR inválido o incompleto');
      } catch (e) {
        // Si falla el parsing JSON, continuar con otros formatos
        // No es JSON válido, intentar otros formatos
      }
    }

    // 1. Formato: nodo:id (ej: nodo:P1_Entrada_1)
    if (qrData.startsWith('nodo:')) {
      final id = qrData.replaceFirst('nodo:', '');
      return QRResult.nodo(id: id, piso: _extraerPisoDeId(id) ?? pisoActual);
    }

    // 2. Formato: ubicacion:alias (ej: ubicacion:Entrada Principal)
    if (qrData.startsWith('ubicacion:')) {
      final alias = qrData.replaceFirst('ubicacion:', '');
      final id = aliasUbicaciones[alias];
      if (id != null) {
        return QRResult.nodo(id: id, piso: _extraerPisoDeId(id) ?? pisoActual);
      } else {
        return QRResult.error('Alias "$alias" no encontrado');
      }
    }

    // 3. Formato: ruta:origen|destino
    if (qrData.startsWith('ruta:')) {
      final partes = qrData.replaceFirst('ruta:', '').split('|');
      if (partes.length == 2) {
        return QRResult.ruta(
          origen: partes[0],
          destino: partes[1],
          piso: pisoActual,
        );
      } else {
        return QRResult.error(
            'Formato de ruta inválido. Use: ruta:origen|destino');
      }
    }

    // 4. Formato: piso:X|nodo:Y
    if (qrData.startsWith('piso:')) {
      final partes = qrData.split('|');
      int? piso;
      String? nodoId;

      for (var parte in partes) {
        if (parte.startsWith('piso:')) {
          piso = int.tryParse(parte.replaceFirst('piso:', ''));
        } else if (parte.startsWith('nodo:')) {
          nodoId = parte.replaceFirst('nodo:', '');
        }
      }

      if (piso != null && nodoId != null) {
        return QRResult.nodo(id: nodoId, piso: piso);
      } else {
        return QRResult.error(
            'Formato piso inválido. Use: piso:1|nodo:P1_Entrada_1');
      }
    }

    // 5. Formato: coordenadas SVG (coord:x,y)
    if (qrData.startsWith('coord:')) {
      final coords = qrData.replaceFirst('coord:', '').split(',');
      if (coords.length == 2) {
        final x = double.tryParse(coords[0]);
        final y = double.tryParse(coords[1]);
        if (x != null && y != null) {
          return QRResult.coordenadasSVG(x: x, y: y, piso: pisoActual);
        }
      }
      return QRResult.error(
          'Formato coordenadas inválido. Use: coord:1004,460');
    }

    // 6. ID directo (asumimos que es un nodo del grafo)
    if (_esIdNodoValido(qrData)) {
      return QRResult.nodo(
          id: qrData, piso: _extraerPisoDeId(qrData) ?? pisoActual);
    }

    // 7. Verificar si es un alias
    final idPorAlias = aliasUbicaciones[qrData];
    if (idPorAlias != null) {
      return QRResult.nodo(
          id: idPorAlias, piso: _extraerPisoDeId(idPorAlias) ?? pisoActual);
    }

    return QRResult.error('Formato QR no reconocido: $qrData');
  }

  // ==================== GENERADOR DE CÓDIGOS QR ====================
  static String generarQRParaNodo(String idNodo, [int? piso]) {
    if (piso != null) {
      return 'piso:$piso|nodo:$idNodo';
    }
    return 'nodo:$idNodo';
  }

  static String generarQRParaAlias(String alias) {
    return 'ubicacion:$alias';
  }

  static String generarQRParaRuta(String origenId, String destinoId) {
    return 'ruta:$origenId|$destinoId';
  }

  static String generarQRParaCoordenadas(double x, double y) {
    return 'coord:${x.toInt()},${y.toInt()}';
  }

  // ==================== INTEGRACIÓN CON GRAFOS ====================
  static Future<Map<String, dynamic>> procesarQRConGrafo(
    String qrData,
    int pisoActual,
    Grafo grafo,
  ) async {
    final resultado = parseQRCode(qrData, pisoActual);

    if (!resultado.esValido) {
      throw Exception(resultado.mensajeError);
    }

    switch (resultado.tipo) {
      case TipoQRResultado.nodo:
        // Buscar nodo en el grafo
        final nodo = grafo.getNodo(resultado.id!);
        if (nodo == null) {
          throw Exception('Nodo ${resultado.id} no encontrado en el grafo');
        }

        return {
          'tipo': 'nodo',
          'nodo': {
            'id': nodo.id,
            'x': nodo.x,
            'y': nodo.y,
          },
          'piso': resultado.piso,
          'qrData': qrData,
        };

      case TipoQRResultado.ruta:
        // Calcular ruta usando A*
        final aStar = AStar(grafo);
        final ruta = aStar.calcular(
          origen: resultado.origen!,
          destino: resultado.destino!,
        );

        if (ruta.isEmpty) {
          throw Exception(
              'No se encontró ruta entre ${resultado.origen} y ${resultado.destino}');
        }

        // Calcular distancia total
        final mapaAdj = grafo.generarMapaAdyacencia();
        double distanciaTotal = 0;
        for (var i = 0; i < ruta.length - 1; i++) {
          final a = ruta[i];
          final b = ruta[i + 1];
          distanciaTotal += mapaAdj[a]![b]!;
        }

        return {
          'tipo': 'ruta',
          'ruta': ruta,
          'origen': resultado.origen,
          'destino': resultado.destino,
          'distancia': distanciaTotal,
          'pasos': ruta.length,
          'piso': resultado.piso,
          'qrData': qrData,
        };

      case TipoQRResultado.coordenadasSVG:
        return {
          'tipo': 'coordenadas',
          'x': resultado.x,
          'y': resultado.y,
          'piso': resultado.piso,
          'qrData': qrData,
        };

      case TipoQRResultado.error:
        throw Exception(resultado.mensajeError);
    }
  }

  // ==================== HELPERS ====================
  static int? _extraerPisoDeId(String id) {
    // Extraer número de piso del ID (ej: P1_Entrada_1 -> 1)
    final regex = RegExp(r'P(\d+)_');
    final match = regex.firstMatch(id);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  static bool _esIdNodoValido(String id) {
    // Verificar si el ID sigue el patrón de nodos del sistema
    return id.startsWith('P') && id.contains('_') && !id.contains(' ');
  }

  static bool esQRValido(String qrData) {
    if (qrData.isEmpty) return false;

    // Verificar formato JSON
    if (qrData.startsWith('{') && qrData.endsWith('}')) {
      try {
        final Map<String, dynamic> jsonData = json.decode(qrData);
        // Debe tener al menos 'type' e 'id' o coordenadas
        if (jsonData.containsKey('type')) {
          final type = jsonData['type'];
          if (type == 'nodo' && jsonData.containsKey('id')) return true;
          if (type == 'ruta' &&
              jsonData.containsKey('origen') &&
              jsonData.containsKey('destino')) return true;
          if ((type == 'coordenadas' || type == 'coord') &&
              jsonData.containsKey('x') &&
              jsonData.containsKey('y')) return true;
        }
      } catch (e) {
        // No es JSON válido, continuar con otros formatos
      }
    }

    // Verificar formatos soportados
    if (formatosSoportados.any(qrData.startsWith)) {
      return true;
    }

    // Verificar si es un ID de nodo válido
    if (_esIdNodoValido(qrData)) {
      return true;
    }

    // Verificar si es un alias
    if (aliasUbicaciones.containsKey(qrData)) {
      return true;
    }

    return false;
  }

  static Future<void> copiarQRAlPortapapeles(String contenido) async {
    await Clipboard.setData(ClipboardData(text: contenido));
  }

  static String obtenerAliasParaNodo(String idNodo) {
    // Buscar alias para un nodo (inverso del mapa)
    for (var entry in aliasUbicaciones.entries) {
      if (entry.value == idNodo) {
        return entry.key;
      }
    }
    return idNodo; // Si no tiene alias, devolver el ID
  }
}

// ==================== MODELOS DE RESULTADO ====================
enum TipoQRResultado {
  nodo,
  ruta,
  coordenadasSVG,
  error,
}

class QRResult {
  final TipoQRResultado tipo;
  final String? id;
  final double? x;
  final double? y;
  final String? origen;
  final String? destino;
  final int piso;
  final String? mensajeError;

  QRResult._({
    required this.tipo,
    this.id,
    this.x,
    this.y,
    this.origen,
    this.destino,
    this.piso = 1,
    this.mensajeError,
  });

  factory QRResult.nodo({required String id, int piso = 1}) {
    return QRResult._(tipo: TipoQRResultado.nodo, id: id, piso: piso);
  }

  factory QRResult.ruta({
    required String origen,
    required String destino,
    int piso = 1,
  }) {
    return QRResult._(
      tipo: TipoQRResultado.ruta,
      origen: origen,
      destino: destino,
      piso: piso,
    );
  }

  factory QRResult.coordenadasSVG({
    required double x,
    required double y,
    int piso = 1,
  }) {
    return QRResult._(
      tipo: TipoQRResultado.coordenadasSVG,
      x: x,
      y: y,
      piso: piso,
    );
  }

  factory QRResult.error(String mensaje) {
    return QRResult._(tipo: TipoQRResultado.error, mensajeError: mensaje);
  }

  bool get esValido => tipo != TipoQRResultado.error;
  bool get esRuta => tipo == TipoQRResultado.ruta;
  bool get esNodo => tipo == TipoQRResultado.nodo;
  bool get esCoordenadas => tipo == TipoQRResultado.coordenadasSVG;
}
