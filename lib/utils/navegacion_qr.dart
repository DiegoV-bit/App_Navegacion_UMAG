import 'package:flutter/material.dart';
import '../models/grafo.dart';
import 'codigo_qr.dart';
import 'grafo_loader.dart';
import 'pantalla_lectora_qr.dart';
import 'pantalla_seleccion_destino.dart';

/// Clase que maneja la lógica de navegación basada en códigos QR.
///
/// Esta clase coordina:
/// - El procesamiento de códigos QR escaneados
/// - La navegación entre pantallas según el tipo de QR
/// - La visualización de rutas y ubicaciones
/// - La integración con el sistema de grafos
///
/// Ejemplo de uso:
/// ```dart
/// final qrNav = QRNavigation(
///   context: context,
///   pisoActual: 1,
///   grafo: grafo,
/// );
/// await qrNav.procesarQR(qrData);
/// ```
class QRNavigation {
  /// Contexto de Flutter necesario para la navegación entre pantallas
  final BuildContext context;

  /// Número del piso actual donde se realiza la navegación (1-4)
  final int pisoActual;

  /// Grafo del piso actual con todos los nodos y conexiones
  final Grafo grafo;

  /// Constructor de la clase de navegación QR.
  ///
  /// Parámetros requeridos:
  /// - [context]: BuildContext de Flutter para navegación
  /// - [pisoActual]: Número de piso donde se está navegando
  /// - [grafo]: Grafo cargado del piso actual
  QRNavigation({
    required this.context,
    required this.pisoActual,
    required this.grafo,
  });

  /// Procesa un código QR escaneado y ejecuta la acción correspondiente.
  ///
  /// Este método:
  /// 1. Procesa el QR usando [QRUtils.procesarQRConGrafo]
  /// 2. Determina el tipo de resultado (nodo, ruta o coordenadas)
  /// 3. Navega a la pantalla apropiada según el tipo
  ///
  /// Parámetros:
  /// - [qrData]: Contenido del código QR escaneado
  ///
  /// Lanza:
  /// - Exception si hay error en el procesamiento del QR
  ///
  /// Tipos de navegación:
  /// - Nodo: Abre pantalla de selección de destino
  /// - Ruta: Muestra diálogo con ruta calculada
  /// - Coordenadas: Muestra diálogo con coordenadas
  Future<void> procesarQR(String qrData) async {
    try {
      // Procesar QR con el grafo actual
      final resultado = await QRUtils.procesarQRConGrafo(
        qrData,
        pisoActual,
        grafo,
      );

      // Navegar según el tipo de resultado
      switch (resultado['tipo']) {
        case 'nodo':
          await _navegarANodo(resultado['nodo'] as Map<String, dynamic>);
          break;

        case 'ruta':
          await _mostrarRuta(resultado);
          break;

        case 'coordenadas':
          await _mostrarCoordenadas(resultado);
          break;

        default:
          _mostrarError('Tipo de resultado no soportado: ${resultado['tipo']}');
      }
    } catch (e) {
      _mostrarError('Error procesando QR: $e');
    }
  }

  /// Navega a la pantalla de selección de destino para un nodo escaneado.
  ///
  /// Este método:
  /// 1. Extrae el ID del nodo desde los datos
  /// 2. Abre [PantallaSeleccionDestino] con el nodo como origen
  /// 3. Espera a que el usuario seleccione un destino
  /// 4. Retorna el resultado al mapa o cierra el scanner
  ///
  /// Parámetros:
  /// - [nodoData]: Map con la información del nodo {'id': String, 'x': double, 'y': double}
  Future<void> _navegarANodo(Map<String, dynamic> nodoData) async {
    final nodoId = nodoData['id'] as String;

    // Abrir la pantalla de selección de destino (sin cerrar el scanner aún)
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaSeleccionDestino(
          nodoOrigenId: nodoId,
          pisoActual: pisoActual,
          grafo: grafo,
        ),
      ),
    );

    // Verificar que el contexto todavía sea válido antes de usar Navigator
    if (!context.mounted) return;

    // Si se calculó una ruta, cerrar el scanner y regresar al mapa con la ruta
    if (resultado != null && resultado is Map<String, dynamic>) {
      Navigator.pop(context, resultado);
    } else {
      // Si se canceló, solo cerrar el scanner sin resultado
      Navigator.pop(context);
    }
  }

  /// Muestra un diálogo con la información de una ruta calculada.
  ///
  /// Presenta al usuario:
  /// - Origen y destino de la ruta
  /// - Distancia total
  /// - Número de pasos
  /// - Lista detallada de todos los puntos de la ruta
  /// - Opción para iniciar navegación paso a paso
  ///
  /// Parámetros:
  /// - [rutaData]: Map con 'ruta', 'origen', 'destino', 'distancia'
  Future<void> _mostrarRuta(Map<String, dynamic> rutaData) async {
    final List<String> ruta = rutaData['ruta'] as List<String>;
    final String origen = rutaData['origen'] as String;
    final String destino = rutaData['destino'] as String;
    final double distancia = rutaData['distancia'] as double;

    // Verificar que el contexto esté montado
    if (!context.mounted) return;

    // Mostrar diálogo con la ruta
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruta Encontrada'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 Origen: ${QRUtils.obtenerAliasParaNodo(origen)}'),
              Text('🎯 Destino: ${QRUtils.obtenerAliasParaNodo(destino)}'),
              const SizedBox(height: 8),
              Text('📏 Distancia: ${distancia.toStringAsFixed(1)} unidades'),
              Text('👣 Pasos: ${ruta.length}'),
              const SizedBox(height: 16),
              const Text(
                'Recorrido:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ruta.length,
                  itemBuilder: (context, index) {
                    final paso = ruta[index];
                    final alias = QRUtils.obtenerAliasParaNodo(paso);
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: index == 0
                            ? Colors.green
                            : index == ruta.length - 1
                                ? Colors.red
                                : Colors.blue,
                        radius: 14,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        alias,
                        style: TextStyle(
                          fontWeight: paso == origen || paso == destino
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: paso != alias ? Text(paso) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar scanner
              _iniciarNavegacionPasoAPaso(ruta);
            },
            child: const Text('Iniciar Navegación'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo con coordenadas SVG escaneadas desde un QR.
  ///
  /// Presenta:
  /// - Número de piso
  /// - Coordenadas X e Y en el sistema SVG
  /// - Opción para ver la ubicación en el mapa
  ///
  /// Parámetros:
  /// - [coordData]: Map con 'x', 'y', 'piso'
  Future<void> _mostrarCoordenadas(Map<String, dynamic> coordData) async {
    final double x = coordData['x'] as double;
    final double y = coordData['y'] as double;
    final int piso = coordData['piso'] as int;

    // Verificar que el contexto esté montado
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coordenadas Encontradas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piso: $piso'),
            Text('Coordenada X: ${x.toInt()}'),
            Text('Coordenada Y: ${y.toInt()}'),
            const SizedBox(height: 16),
            const Text(
              'Estas coordenadas corresponden a una ubicación en el mapa SVG.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar scanner
              // Podrías navegar al mapa y centrar en estas coordenadas
              _mostrarEnMapa(x, y, piso);
            },
            child: const Text('Ver en Mapa'),
          ),
        ],
      ),
    );
  }

  /// Inicia la navegación paso a paso para una ruta calculada.
  ///
  /// Esta es una funcionalidad futura que podría incluir:
  /// - Instrucciones paso a paso
  /// - Navegación con audio
  /// - Integración con realidad aumentada (AR)
  ///
  /// Parámetros:
  /// - [ruta]: Lista de IDs de nodos que conforman el camino
  void _iniciarNavegacionPasoAPaso(List<String> ruta) {
    // Aquí implementarías la navegación paso a paso
    // Por ahora mostramos un mensaje y cerramos el scanner
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegación iniciada: ${ruta.length} pasos'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // En un futuro, podrías:
    // 1. Abrir una pantalla de navegación paso a paso
    // 2. Mostrar instrucciones de audio
    // 3. Integrar con AR para navegación visual
  }

  /// Muestra una ubicación específica en el mapa basándose en coordenadas.
  ///
  /// Funcionalidad futura que podría:
  /// - Navegar al piso correspondiente
  /// - Centrar el mapa en las coordenadas
  /// - Mostrar un marcador en la ubicación
  ///
  /// Parámetros:
  /// - [x]: Coordenada X en el sistema SVG
  /// - [y]: Coordenada Y en el sistema SVG
  /// - [piso]: Número de piso
  void _mostrarEnMapa(double x, double y, int piso) {
    // Verificar que el contexto esté montado
    if (!context.mounted) return;

    // Mostrar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Centrando mapa en coordenadas: X=${x.toInt()}, Y=${y.toInt()}'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Aquí podrías:
    // 1. Navegar al piso correspondiente
    // 2. Centrar el mapa en las coordenadas
    // 3. Mostrar un marcador en la ubicación
  }

  /// Muestra un mensaje de error al usuario.
  ///
  /// - Muestra un SnackBar rojo con el mensaje de error
  /// - Automáticamente cierra el scanner después de 2 segundos
  ///
  /// Parámetros:
  /// - [mensaje]: Descripción del error a mostrar
  void _mostrarError(String mensaje) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reanudar escaneo después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context); // Volver al scanner
      }
    });
  }

  /// Método estático para abrir el scanner QR fácilmente desde cualquier pantalla.
  ///
  /// Este método de conveniencia:
  /// 1. Carga el grafo del piso especificado
  /// 2. Abre la pantalla del scanner QR
  /// 3. Maneja errores de carga del grafo
  ///
  /// Parámetros:
  /// - [context]: BuildContext de Flutter
  /// - [pisoActual]: Número del piso actual
  /// - [rutaGrafoJson]: Ruta al archivo JSON del grafo (ejemplo: "lib/data/grafo_piso1.json")
  ///
  /// Ejemplo:
  /// ```dart
  /// await QRNavigation.escanearQRParaMapa(
  ///   context: context,
  ///   pisoActual: 1,
  ///   rutaGrafoJson: 'lib/data/grafo_piso1.json',
  /// );
  /// ```
  static Future<void> escanearQRParaMapa({
    required BuildContext context,
    required int pisoActual,
    required String rutaGrafoJson,
  }) async {
    try {
      // Cargar el grafo del piso actual
      final grafo = await cargarGrafo(rutaGrafoJson);

      // Navegar al scanner
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(
            pisoActual: pisoActual,
            grafo: grafo,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el grafo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
