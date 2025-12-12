import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;
  bool _flashOn = false;

  @override
  void dispose() {
    controller?.dispose();
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
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).primaryColor,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: 250,
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
                color: Colors.black.withOpacity(0.7),
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
                  backgroundColor: Colors.black.withOpacity(0.7),
                  child: Icon(
                    _flashOn ? Icons.flash_off : Icons.flash_on,
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanning) return;

      setState(() {
        _isScanning = false;
      });

      controller.pauseCamera();

      // Procesar el QR
      _procesarQR(scanData.code);
    });
  }

  void _procesarQR(String? qrData) async {
    if (qrData == null || qrData.isEmpty) {
      _mostrarError('QR vacío o no legible');
      return;
    }

    // Validar formato
    if (!QRUtils.esQRValido(qrData)) {
      _mostrarError('Formato QR no soportado');
      return;
    }

    // Crear navegador QR y procesar
    final qrNav = QRNavigation(
      context: context,
      pisoActual: widget.pisoActual,
      grafo: widget.grafo,
    );

    await qrNav.procesarQR(qrData);
  }

  void _toggleFlash() async {
    try {
      await controller?.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    } catch (e) {
      // Flash no disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flash no disponible en este dispositivo'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              '📍 Nodo individual',
              'nodo:P1_Entrada_1',
              Colors.green,
            ),
            _buildInstructionItem(
              '🔄 Ruta completa',
              'ruta:P1_Entrada_1|P1_Pasillo_Ingenieria_Centro',
              Colors.orange,
            ),
            _buildInstructionItem(
              '🏢 Piso específico',
              'piso:1|nodo:P1_Entrada_1',
              Colors.purple,
            ),
            _buildInstructionItem(
              '🗺️ Coordenadas SVG',
              'coord:1004,460',
              Colors.blue,
            ),
            _buildInstructionItem(
              '🏷️ Alias de ubicación',
              'ubicacion:Entrada Principal',
              Colors.teal,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Consejo: Los códigos QR se pueden generar desde el modo debug en la pantalla del mapa.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String titulo, String ejemplo, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
      ),
    );

    // Reanudar escaneo después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && controller != null) {
        setState(() {
          _isScanning = true;
        });
        controller?.resumeCamera();
      }
    });
  }
}
