import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/codigo_qr.dart';
import '../utils/navegacion_qr.dart';
import '../models/grafo.dart';

class QRScannerScreen extends StatefulWidget {
  final int pisoActual;
  final Grafo grafo;

  const QRScannerScreen({
    super.key,
    required this.pisoActual,
    required this.grafo,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  bool _isScanning = true;
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

  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

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

// Custom Painter para el overlay del scanner
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
