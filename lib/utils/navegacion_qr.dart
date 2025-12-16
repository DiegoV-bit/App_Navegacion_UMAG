import 'package:flutter/material.dart';
import '../models/grafo.dart';
import 'codigo_qr.dart';
import 'grafo_loader.dart';
import 'pantalla_lectora_qr.dart';
import 'pantalla_seleccion_destino.dart';

class QRNavigation {
  final BuildContext context;
  final int pisoActual;
  final Grafo grafo;

  QRNavigation({
    required this.context,
    required this.pisoActual,
    required this.grafo,
  });

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

    // Si se calculó una ruta, cerrar el scanner y regresar al mapa con la ruta
    if (resultado != null && resultado is Map<String, dynamic>) {
      Navigator.pop(context, resultado);
    } else {
      // Si se canceló, solo cerrar el scanner sin resultado
      Navigator.pop(context);
    }
  }

  Future<void> _mostrarRuta(Map<String, dynamic> rutaData) async {
    final List<String> ruta = rutaData['ruta'] as List<String>;
    final String origen = rutaData['origen'] as String;
    final String destino = rutaData['destino'] as String;
    final double distancia = rutaData['distancia'] as double;

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

  Future<void> _mostrarCoordenadas(Map<String, dynamic> coordData) async {
    final double x = coordData['x'] as double;
    final double y = coordData['y'] as double;
    final int piso = coordData['piso'] as int;

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

  void _iniciarNavegacionPasoAPaso(List<String> ruta) {
    // Aquí implementarías la navegación paso a paso
    // Por ahora mostramos un mensaje y cerramos el scanner
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

  void _mostrarEnMapa(double x, double y, int piso) {
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

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reanudar escaneo después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context); // Volver al scanner
      }
    });
  }

  // Método estático para fácil acceso
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
