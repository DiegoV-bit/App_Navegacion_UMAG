import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/codigo_qr.dart';
import '../utils/navegacion_qr.dart';
import '../models/grafo.dart';

/// Pantalla que muestra la cámara para escanear códigos QR.
///
/// Esta pantalla proporciona:
/// - Vista de cámara en tiempo real usando [MobileScanner]
/// - Detección automática de códigos QR
/// - Overlay visual con marco de escaneo
/// - Control de flash/linterna
/// - Validación de formatos QR soportados
/// - Procesamiento e integración con el sistema de navegación
///
/// Ejemplo de uso:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => QRScannerScreen(
///       pisoActual: 1,
///       grafo: grafo,
///     ),
///   ),
/// );
/// ```
class QRScannerScreen extends StatefulWidget {
  /// Número del piso actual donde se está escaneando (1-4)
  final int pisoActual;

  /// Grafo del piso actual con nodos y conexiones
  final Grafo grafo;

  const QRScannerScreen({
    super.key,
    required this.pisoActual,
    required this.grafo,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

/// Estado de la pantalla del scanner QR.
class _QRScannerScreenState extends State<QRScannerScreen> {
  /// Controlador del scanner de código de barras/QR
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  /// Indica si el scanner está actualmente escaneando
  /// Se desactiva temporalmente al detectar un QR para evitar escaneos múltiples
  bool _isScanning = true;

  /// Indica si la linterna/flash está activada
  bool _torchEnabled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarInstrucciones,
            tooltip: 'Instrucciones',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Vista del scanner
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (!_isScanning) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final String? qrData = barcodes.first.rawValue;
              if (qrData != null && qrData.isNotEmpty) {
                setState(() {
                  _isScanning = false;
                });

                controller.stop();
                _procesarQR(qrData);
              }
            },
          ),

          // Overlay con marco de escaneo
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
              child: const SizedBox.expand(),
            ),
          ),

          // Overlay con información
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Piso ${widget.pisoActual}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Apunte al código QR de una ubicación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Botones de control
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'flash',
                  onPressed: _toggleFlash,
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: Icon(
                    _torchEnabled ? Icons.flash_off : Icons.flash_on,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'cancel',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Procesa un código QR escaneado.
  ///
  /// Este método:
  /// 1. Valida que el QR no esté vacío
  /// 2. Verifica que el formato sea soportado
  /// 3. Crea un navegador QR y delega el procesamiento
  ///
  /// Parámetros:
  /// - [qrData]: Contenido del código QR escaneado
  void _procesarQR(String qrData) async {
    if (qrData.isEmpty) {
      _mostrarError('QR vacío o no legible');
      return;
    }

    // Validar formato
    if (!QRUtils.esQRValido(qrData)) {
      _mostrarError('Formato QR no soportado');
      return;
    }

    // Verificar que el widget esté montado antes de continuar
    if (!mounted) return;

    // Crear navegador QR y procesar
    final qrNav = QRNavigation(
      context: context,
      pisoActual: widget.pisoActual,
      grafo: widget.grafo,
    );

    await qrNav.procesarQR(qrData);
  }

  /// Alterna el estado de la linterna/flash de la cámara.
  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  /// Muestra un bottom sheet con las instrucciones de formatos QR soportados.
  ///
  /// Presenta ejemplos de todos los formatos válidos:
  /// - Nodo: nodo:P1_Entrada_1
  /// - Ubicación: ubicacion:Entrada Principal
  /// - Ruta: ruta:P1_Entrada_1|P1_Pasillo_Norte
  /// - Piso + Nodo: piso:1|nodo:P1_Entrada_1
  /// - Coordenadas: coord:1004,460
  void _mostrarInstrucciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formatos QR Soportados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFormatoItem(
              'Nodo',
              'nodo:P1_Entrada_1',
              Colors.blue,
            ),
            _buildFormatoItem(
              'Ubicación',
              'ubicacion:Entrada Principal',
              Colors.green,
            ),
            _buildFormatoItem(
              'Ruta',
              'ruta:P1_Entrada_1|P1_Pasillo_Norte',
              Colors.orange,
            ),
            _buildFormatoItem(
              'Piso + Nodo',
              'piso:1|nodo:P1_Entrada_1',
              Colors.purple,
            ),
            _buildFormatoItem(
              'Coordenadas',
              'coord:1004,460',
              Colors.teal,
            ),
            const SizedBox(height: 16),
            const Text(
              'Apunte la cámara al código QR para escanearlo automáticamente.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un item de formato QR en el diálogo de ayuda.
  ///
  /// Parámetros:
  /// - [titulo]: Nombre del formato (ejemplo: "Nodo", "Ruta")
  /// - [ejemplo]: Cadena de ejemplo del formato
  /// - [color]: Color temático para el item
  Widget _buildFormatoItem(String titulo, String ejemplo, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            ejemplo,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de error y reinicia el scanner.
  ///
  /// - Presenta un SnackBar con el mensaje de error
  /// - Proporciona botón para reintentar inmediatamente
  /// - Automáticamente reinicia el scanner después de 2 segundos
  ///
  /// Parámetros:
  /// - [mensaje]: Descripción del error a mostrar
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isScanning = true;
            });
            controller.start();
          },
        ),
      ),
    );

    // Reiniciar scanner después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
        controller.start();
      }
    });
  }
}

/// Custom Painter que dibuja el overlay visual sobre la cámara del scanner.
///
/// Dibuja:
/// - Área oscura semi-transparente alrededor del marco de escaneo
/// - Marco de escaneo con esquinas redondeadas y resaltadas
/// - Esquinas con líneas azules para indicar el área de escaneo
///
/// El área de escaneo es un cuadrado de 250x250 px centrado en la pantalla.
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double scanAreaSize = 250.0;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Dibujar área oscura alrededor
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
              RRect.fromRectAndRadius(scanRect, const Radius.circular(12))),
      ),
      backgroundPaint,
    );

    // Dibujar esquinas del marco
    final Paint cornerPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30;
    const double cornerRadius = 12;

    // Esquina superior izquierda
    canvas.drawPath(
      Path()
        ..moveTo(left + cornerRadius, top)
        ..lineTo(left + cornerLength, top)
        ..moveTo(left, top + cornerRadius)
        ..lineTo(left, top + cornerLength),
      cornerPaint,
    );

    // Esquina superior derecha
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize - cornerRadius, top)
        ..moveTo(left + scanAreaSize, top + cornerRadius)
        ..lineTo(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );

    // Esquina inferior izquierda
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize - cornerRadius)
        ..moveTo(left + cornerRadius, top + scanAreaSize)
        ..lineTo(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Esquina inferior derecha
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize, top + scanAreaSize - cornerLength)
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerRadius)
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize - cornerRadius, top + scanAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
