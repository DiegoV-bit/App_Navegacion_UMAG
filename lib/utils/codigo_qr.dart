import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'dart:convert';
import '../models/grafo.dart';
import '../utils/a_estrella.dart';

/// Clase de utilidades para el manejo y procesamiento de códigos QR.
///
/// Esta clase proporciona funcionalidades para:
/// - Parsear diferentes formatos de códigos QR
/// - Generar códigos QR para nodos, rutas y coordenadas
/// - Integrar códigos QR con el sistema de navegación basado en grafos
/// - Validar formatos de QR soportados
/// - Manejar alias amigables para ubicaciones
///
/// Formatos QR soportados:
/// 1. JSON: {"type": "nodo", "id": "P1_Entrada_1", "piso": 1}
/// 2. nodo:P1_Entrada_1
/// 3. ubicacion:Entrada Principal
/// 4. ruta:P1_Entrada_1|P1_Sala_101
/// 5. piso:1|nodo:P1_Entrada_1
/// 6. coord:1004,460
class QRUtils {
  // ==================== FORMATOS QR SOPORTADOS ====================
  /// Lista de prefijos de formatos QR reconocidos por el sistema.
  ///
  /// Cada formato tiene un propósito específico:
  /// - `nodo:` - Identifica un nodo específico por su ID
  /// - `ruta:` - Define una ruta entre dos nodos
  /// - `piso:` - Especifica piso y nodo
  /// - `coord:` - Coordenadas SVG directas
  /// - `ubicacion:` - Usa alias amigables de ubicaciones
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
  /// Mapa de alias amigables para ubicaciones comunes del edificio.
  ///
  /// Permite usar nombres legibles en lugar de IDs técnicos en los códigos QR.
  /// Por ejemplo: "Entrada Principal" en lugar de "P1_Entrada_1"
  ///
  /// Estos alias se pueden usar en códigos QR con el formato:
  /// `ubicacion:Entrada Principal`
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
  /// Analiza y parsea un código QR escaneado, extrayendo la información contenida.
  ///
  /// Este método procesa diferentes formatos de códigos QR y retorna un [QRResult]
  /// que contiene la información extraída y el tipo de QR detectado.
  ///
  /// Formatos procesados (en orden de prioridad):
  /// 1. JSON: {"type": "nodo", "id": "P1_Entrada_1", "piso": 1}
  /// 2. nodo:P1_Entrada_1
  /// 3. ubicacion:Entrada Principal
  /// 4. ruta:P1_Entrada_1|P1_Sala_101
  /// 5. piso:1|nodo:P1_Entrada_1
  /// 6. coord:1004,460
  /// 7. ID directo (ejemplo: P1_Entrada_1)
  ///
  /// Parámetros:
  /// - [qrData]: Contenido del código QR escaneado
  /// - [pisoActual]: Piso actual donde se escanea (usado como default si no se especifica)
  ///
  /// Retorna:
  /// - [QRResult] con la información parseada o un error si el formato es inválido
  ///
  /// Ejemplo:
  /// ```dart
  /// final resultado = QRUtils.parseQRCode('nodo:P1_Entrada_1', 1);
  /// if (resultado.esValido) {
  ///   print('Nodo encontrado: ${resultado.id}');
  /// }
  /// ```
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
  /// Genera una cadena de código QR para un nodo específico.
  ///
  /// Parámetros:
  /// - [idNodo]: ID del nodo (ejemplo: "P1_Entrada_1")
  /// - [piso]: Número de piso (opcional). Si se proporciona, incluye el piso en el QR
  ///
  /// Retorna:
  /// - Cadena en formato "piso:X|nodo:ID" si se especifica piso
  /// - Cadena en formato "nodo:ID" si no se especifica piso
  static String generarQRParaNodo(String idNodo, [int? piso]) {
    if (piso != null) {
      return 'piso:$piso|nodo:$idNodo';
    }
    return 'nodo:$idNodo';
  }

  /// Genera una cadena de código QR usando un alias de ubicación.
  ///
  /// Parámetros:
  /// - [alias]: Nombre amigable de la ubicación (ejemplo: "Entrada Principal")
  ///
  /// Retorna:
  /// - Cadena en formato "ubicacion:ALIAS"
  static String generarQRParaAlias(String alias) {
    return 'ubicacion:$alias';
  }

  /// Genera una cadena de código QR para una ruta predefinida.
  ///
  /// Parámetros:
  /// - [origenId]: ID del nodo de origen
  /// - [destinoId]: ID del nodo de destino
  ///
  /// Retorna:
  /// - Cadena en formato "ruta:ORIGEN|DESTINO"
  static String generarQRParaRuta(String origenId, String destinoId) {
    return 'ruta:$origenId|$destinoId';
  }

  /// Genera una cadena de código QR para coordenadas SVG específicas.
  ///
  /// Parámetros:
  /// - [x]: Coordenada X en el sistema SVG
  /// - [y]: Coordenada Y en el sistema SVG
  ///
  /// Retorna:
  /// - Cadena en formato "coord:X,Y" (redondeado a enteros)
  static String generarQRParaCoordenadas(double x, double y) {
    return 'coord:${x.toInt()},${y.toInt()}';
  }

  // ==================== INTEGRACIÓN CON GRAFOS ====================
  /// Procesa un código QR y lo integra con el grafo de navegación.
  ///
  /// Este método realiza el procesamiento completo de un QR:
  /// 1. Parsea el código QR
  /// 2. Valida que la información sea correcta
  /// 3. Busca nodos en el grafo si es necesario
  /// 4. Calcula rutas usando A* si es un QR de ruta
  /// 5. Retorna toda la información necesaria para la navegación
  ///
  /// Parámetros:
  /// - [qrData]: Contenido del código QR escaneado
  /// - [pisoActual]: Piso donde se realiza el escaneo
  /// - [grafo]: Grafo del piso actual con nodos y conexiones
  ///
  /// Retorna:
  /// - Map con la información procesada según el tipo de QR:
  ///   - Para nodos: {'tipo': 'nodo', 'nodo': {...}, 'piso': X}
  ///   - Para rutas: {'tipo': 'ruta', 'ruta': [...], 'distancia': X}
  ///   - Para coordenadas: {'tipo': 'coordenadas', 'x': X, 'y': Y}
  ///
  /// Lanza:
  /// - [Exception] si el QR es inválido, el nodo no existe, o no hay ruta
  ///
  /// Ejemplo:
  /// ```dart
  /// try {
  ///   final resultado = await QRUtils.procesarQRConGrafo(
  ///     'nodo:P1_Entrada_1',
  ///     1,
  ///     grafo,
  ///   );
  ///   print('Tipo: ${resultado['tipo']}');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
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
  /// Extrae el número de piso del ID de un nodo.
  ///
  /// Parámetros:
  /// - [id]: ID del nodo (ejemplo: "P1_Entrada_1", "P2_Lab_Fisica")
  ///
  /// Retorna:
  /// - Número de piso (1, 2, 3, 4) si el formato es válido
  /// - null si no se puede extraer el piso
  ///
  /// Ejemplo:
  /// ```dart
  /// final piso = _extraerPisoDeId('P1_Entrada_1'); // Retorna 1
  /// final piso2 = _extraerPisoDeId('P3_Sala_301'); // Retorna 3
  /// ```
  static int? _extraerPisoDeId(String id) {
    // Extraer número de piso del ID (ej: P1_Entrada_1 -> 1)
    final regex = RegExp(r'P(\d+)_');
    final match = regex.firstMatch(id);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Verifica si un string tiene el formato válido de un ID de nodo.
  ///
  /// Un ID válido debe:
  /// - Comenzar con 'P' (de Piso)
  /// - Contener al menos un guion bajo '_'
  /// - No contener espacios
  ///
  /// Parámetros:
  /// - [id]: String a validar
  ///
  /// Retorna:
  /// - true si el formato es válido
  /// - false en caso contrario
  static bool _esIdNodoValido(String id) {
    // Verificar si el ID sigue el patrón de nodos del sistema
    return id.startsWith('P') && id.contains('_') && !id.contains(' ');
  }

  /// Valida si un código QR tiene un formato reconocido por el sistema.
  ///
  /// Verifica contra todos los formatos soportados:
  /// - Formato JSON
  /// - Prefijos estándar (nodo:, ruta:, ubicacion:, etc.)
  /// - IDs de nodo directos
  /// - Alias de ubicaciones
  ///
  /// Parámetros:
  /// - [qrData]: Contenido del QR a validar
  ///
  /// Retorna:
  /// - true si el formato es reconocido
  /// - false si el formato no es válido
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
              jsonData.containsKey('destino')) {
            return true;
          }
          if ((type == 'coordenadas' || type == 'coord') &&
              jsonData.containsKey('x') &&
              jsonData.containsKey('y')) {
            return true;
          }
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

  /// Copia un contenido de QR al portapapeles del dispositivo.
  ///
  /// Parámetros:
  /// - [contenido]: String a copiar al portapapeles
  ///
  /// Ejemplo:
  /// ```dart
  /// await QRUtils.copiarQRAlPortapapeles('nodo:P1_Entrada_1');
  /// ```
  static Future<void> copiarQRAlPortapapeles(String contenido) async {
    await Clipboard.setData(ClipboardData(text: contenido));
  }

  /// Obtiene el alias amigable de un nodo si existe.
  ///
  /// Busca en el mapa de alias para encontrar un nombre legible
  /// asociado con el ID del nodo.
  ///
  /// Parámetros:
  /// - [idNodo]: ID del nodo (ejemplo: "P1_Entrada_1")
  ///
  /// Retorna:
  /// - Alias amigable si existe (ejemplo: "Entrada Principal")
  /// - El mismo ID si no tiene alias
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
/// Enum que define los tipos posibles de resultados al parsear un código QR.
///
/// - [nodo]: El QR representa un nodo específico del grafo
/// - [ruta]: El QR define una ruta predefinida entre dos nodos
/// - [coordenadasSVG]: El QR contiene coordenadas directas en el sistema SVG
/// - [error]: El QR no pudo ser parseado o es inválido
enum TipoQRResultado {
  nodo,
  ruta,
  coordenadasSVG,
  error,
}

/// Clase que encapsula el resultado de parsear un código QR.
///
/// Almacena toda la información extraída del QR según su tipo:
/// - Para nodos: [id], [piso]
/// - Para rutas: [origen], [destino], [piso]
/// - Para coordenadas: [x], [y], [piso]
/// - Para errores: [mensajeError]
///
/// Uso:
/// ```dart
/// final resultado = QRUtils.parseQRCode('nodo:P1_Entrada_1', 1);
/// if (resultado.esValido) {
///   if (resultado.esNodo) {
///     print('Nodo: ${resultado.id}');
///   }
/// } else {
///   print('Error: ${resultado.mensajeError}');
/// }
/// ```
class QRResult {
  /// Tipo de resultado obtenido del parseo del QR
  final TipoQRResultado tipo;

  /// ID del nodo (solo para tipo nodo)
  final String? id;

  /// Coordenada X en el sistema SVG (solo para tipo coordenadasSVG)
  final double? x;

  /// Coordenada Y en el sistema SVG (solo para tipo coordenadasSVG)
  final double? y;

  /// ID del nodo de origen (solo para tipo ruta)
  final String? origen;

  /// ID del nodo de destino (solo para tipo ruta)
  final String? destino;

  /// Número de piso asociado al resultado
  final int piso;

  /// Mensaje descriptivo del error (solo para tipo error)
  final String? mensajeError;

  /// Constructor privado usado por los factory constructors
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

  /// Crea un resultado de tipo nodo.
  ///
  /// Parámetros:
  /// - [id]: ID del nodo
  /// - [piso]: Número de piso (default: 1)
  factory QRResult.nodo({required String id, int piso = 1}) {
    return QRResult._(tipo: TipoQRResultado.nodo, id: id, piso: piso);
  }

  /// Crea un resultado de tipo ruta.
  ///
  /// Parámetros:
  /// - [origen]: ID del nodo de origen
  /// - [destino]: ID del nodo de destino
  /// - [piso]: Número de piso (default: 1)
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

  /// Crea un resultado de tipo coordenadas SVG.
  ///
  /// Parámetros:
  /// - [x]: Coordenada X en el sistema SVG
  /// - [y]: Coordenada Y en el sistema SVG
  /// - [piso]: Número de piso (default: 1)
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

  /// Crea un resultado de tipo error.
  ///
  /// Parámetros:
  /// - [mensaje]: Descripción del error ocurrido
  factory QRResult.error(String mensaje) {
    return QRResult._(tipo: TipoQRResultado.error, mensajeError: mensaje);
  }

  /// Retorna true si el resultado es válido (no es un error)
  bool get esValido => tipo != TipoQRResultado.error;

  /// Retorna true si el resultado es de tipo ruta
  bool get esRuta => tipo == TipoQRResultado.ruta;

  /// Retorna true si el resultado es de tipo nodo
  bool get esNodo => tipo == TipoQRResultado.nodo;

  /// Retorna true si el resultado es de tipo coordenadas
  bool get esCoordenadas => tipo == TipoQRResultado.coordenadasSVG;
}
