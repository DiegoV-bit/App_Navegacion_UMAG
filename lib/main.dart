import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mi_facultad_umag/utils/codigo_qr.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'models/grafo.dart';
import 'utils/a_estrella.dart';
import 'utils/pantalla_lectora_qr.dart';
import 'utils/gestor_multipiso.dart';

// ==================== CONFIGURACIÓN DEBUG ====================
// Cambiar a false cuando la aplicación esté lista para producción
const bool kDebugMode = false;
// =============================================================

// ==================== TIPOS DE NODOS ====================
enum TipoNodo {
  entrada,
  pasillo,
  interseccion,
  esquina,
  puerta,
  escalera,
  ascensor,
  bano,
  puntoInteres,
}

extension TipoNodoExtension on TipoNodo {
  String get nombre {
    switch (this) {
      case TipoNodo.entrada:
        return 'Entrada';
      case TipoNodo.pasillo:
        return 'Pasillo';
      case TipoNodo.interseccion:
        return 'Intersección';
      case TipoNodo.esquina:
        return 'Esquina';
      case TipoNodo.puerta:
        return 'Puerta';
      case TipoNodo.escalera:
        return 'Escalera';
      case TipoNodo.ascensor:
        return 'Ascensor';
      case TipoNodo.bano:
        return 'Baño';
      case TipoNodo.puntoInteres:
        return 'Punto de Interés';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoNodo.entrada:
        return Icons.door_front_door;
      case TipoNodo.pasillo:
        return Icons.straighten;
      case TipoNodo.interseccion:
        return Icons.merge_type;
      case TipoNodo.esquina:
        return Icons.turn_right;
      case TipoNodo.puerta:
        return Icons.meeting_room;
      case TipoNodo.escalera:
        return Icons.stairs;
      case TipoNodo.ascensor:
        return Icons.elevator;
      case TipoNodo.bano:
        return Icons.wc;
      case TipoNodo.puntoInteres:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case TipoNodo.entrada:
        return Colors.green;
      case TipoNodo.pasillo:
        return Colors.blue;
      case TipoNodo.interseccion:
        return Colors.orange;
      case TipoNodo.esquina:
        return Colors.purple;
      case TipoNodo.puerta:
        return Colors.teal;
      case TipoNodo.escalera:
        return Colors.red;
      case TipoNodo.ascensor:
        return Colors.indigo;
      case TipoNodo.bano:
        return Colors.cyan;
      case TipoNodo.puntoInteres:
        return Colors.amber;
    }
  }
}
// =======================================================

void main() {
  // Inicializa la aplicación con la configuración principal.
  runApp(const NavigacionUMAGApp());
}

class NavigacionUMAGApp extends StatelessWidget {
  const NavigacionUMAGApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp establece tema, navegación y punto de entrada visual.
    return MaterialApp(
      title: 'Navegación UMAG',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facultad de Ingeniería UMAG'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          // Fondo con degradado suave para darle jerarquía a la pantalla inicial.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 5,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Navegación Interna',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona el piso que deseas explorar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Cada tarjeta abre el mapa correspondiente al piso seleccionado.
                    _buildPisoCard(
                      context,
                      'Primer Piso',
                      'Laboratorios de la Facultad, salas 50-51',
                      Icons.science,
                      Colors.green,
                      1,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Segundo Piso',
                      'Salas 21-26 y salas 52-56',
                      Icons.school,
                      Colors.orange,
                      2,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Tercer Piso',
                      'Salas 31-36 y departamento de matematicas y fisica',
                      Icons.book,
                      Colors.purple,
                      3,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Cuarto Piso',
                      'Salas 41-44 y sala de conferencias',
                      Icons.business,
                      Colors.red,
                      4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPisoCard(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icono,
    Color color,
    int numeroPiso,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navega hacia la pantalla de mapa enviando piso y título.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PantallaMapa(numeroPiso: numeroPiso, titulo: titulo),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Reemplazamos `withOpacity` (deprecado) por `withAlpha` para evitar warnings.
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class PantallaMapa extends StatefulWidget {
  final int numeroPiso;
  final String titulo;

  const PantallaMapa({
    super.key,
    required this.numeroPiso,
    required this.titulo,
  });

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final TransformationController _transformationController =
      TransformationController();
  List<Map<String, dynamic>> _nodos = [];
  bool _mostrarNodos = true;

  // Variables para modo debug
  bool _modoDebugActivo = kDebugMode;
  final List<Map<String, dynamic>> _coordenadasDebug = [];
  final List<Map<String, dynamic>> _conexionesDebug = [];
  final GlobalKey _containerKey = GlobalKey();

  // Dimensiones del SVG original (predefinidas para cada piso)
  double _svgWidthOriginal = 1200.0;
  double _svgHeightOriginal = 800.0;
  bool _inicializado = false;
  // Límites de zoom (coinciden con los de InteractiveViewer más abajo)
  final double _minScale = 1.0;
  final double _maxScale = 4.0;

  // Variable para almacenar la ruta activa calculada con A*
  final List<String> _rutaActiva = [];

  // Variables para selección manual de origen y destino
  String? _origenSeleccionado;
  String? _destinoSeleccionado;

  // Variables para navegación multi-piso
  final GestorMultiPiso _gestorMultiPiso = GestorMultiPiso();
  int _pasoActualRuta = 0;
  final List<SegmentoRuta> _segmentosRuta = [];
  // OpcionRuta? _rutaActivaMultiPiso; // TODO: Implementar selección de opciones de ruta

  @override
  void initState() {
    super.initState();
    // inicializa configuración y carga del mapa
    _configurarDimensionesSVG();
    _inicializarMapa();
    _inicializarGestorMultiPiso();
  }

  // Inicializar gestor multi-piso
  Future<void> _inicializarGestorMultiPiso() async {
    try {
      await _gestorMultiPiso.cargarTodosLosPisos();
      if (kDebugMode) {
        print('✓ Gestor multi-piso inicializado');
        print(
            '  Conexiones verticales: ${_gestorMultiPiso.conexionesVerticales.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Error al inicializar gestor multi-piso: $e');
      }
    }
  }

  // Configurar dimensiones según el piso (sin cargar el archivo completo)
  void _configurarDimensionesSVG() {
    // Usando sistema de coordenadas 1200x800 para todos los pisos
    // Este sistema se usa para mantener compatibilidad con los nodos existentes
    switch (widget.numeroPiso) {
      case 1:
      case 2:
      case 3:
      case 4:
        _svgWidthOriginal = 1200.0;
        _svgHeightOriginal = 800.0;
        break;
      default:
        _svgWidthOriginal = 1200.0;
        _svgHeightOriginal = 800.0;
    }
  }

  Future<void> _inicializarMapa() async {
    try {
      // Cargar nodos sin setState
      await _cargarNodos();

      // Esperar al primer frame para tener RenderBox disponible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _inicializado = true;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERROR inicialización: $e');
      }
    }
  }

  Future<void> _cargarNodos() async {
    try {
      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      final nodosRaw =
          List<Map<String, dynamic>>.from(data['nodos'] as List<dynamic>);

      // Filtrar nodos vacíos o con datos inválidos
      _nodos = nodosRaw.where((nodo) {
        return nodo['id'] != null &&
            nodo['x'] != null &&
            nodo['y'] != null &&
            (nodo['id'] as String).isNotEmpty;
      }).toList();

      if (kDebugMode) {
        final nodosInvalidos = nodosRaw.length - _nodos.length;
        print('\n════════════════════════════════════════');
        print('📍 CARGA DE NODOS - Piso ${widget.numeroPiso}');
        print('════════════════════════════════════════');
        print('Total de nodos válidos: ${_nodos.length}');
        if (nodosInvalidos > 0) {
          print('⚠️  Nodos inválidos filtrados: $nodosInvalidos');
        }
        print('\nCoordenadas de todos los nodos:');
        for (var i = 0; i < _nodos.length; i++) {
          final nodo = _nodos[i];
          print('  [$i] ${nodo['id']}: x=${nodo['x']}, y=${nodo['y']}');
        }
        print('════════════════════════════════════════\n');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cargando nodos: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar nodos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirScannerQR() async {
    try {
      // Cargar grafo actual
      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      final grafo = Grafo.fromJson(data);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(
            pisoActual: widget.numeroPiso,
            grafo: grafo,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al abrir scanner QR: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir scanner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Offset _calcularPosicionEscalada(double x, double y) {
    if (!_inicializado) {
      return Offset(x, y);
    }

    // Usar el Container principal como referencia
    final RenderBox? containerBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;

    if (containerBox == null || !containerBox.hasSize) {
      return Offset(x, y);
    }

    final containerSize = containerBox.size;

    if (containerSize.width <= 0 || containerSize.height <= 0) {
      return Offset(x, y);
    }

    // Calcular la escala manteniendo aspect ratio (BoxFit.contain)
    final scaleX = containerSize.width / _svgWidthOriginal;
    final scaleY = containerSize.height / _svgHeightOriginal;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calcular dimensiones escaladas del SVG
    final scaledWidth = _svgWidthOriginal * scale;
    final scaledHeight = _svgHeightOriginal * scale;

    // Calcular offsets para centrado (BoxFit.contain centra el contenido)
    final offsetX = (containerSize.width - scaledWidth) / 2;
    final offsetY = (containerSize.height - scaledHeight) / 2;

    // Aplicar transformación y redondear a enteros para consistencia
    final scaledX = ((x * scale) + offsetX).roundToDouble();
    final scaledY = ((y * scale) + offsetY).roundToDouble();

    return Offset(scaledX, scaledY);
  }

  // Método inverso: de coordenadas de pantalla a coordenadas SVG
  Offset _calcularCoordenadasSVG(Offset screenPosition) {
    final RenderBox? containerBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;

    if (containerBox == null) {
      return screenPosition;
    }

    final containerSize = containerBox.size;

    // Calcular la escala
    final scaleX = containerSize.width / _svgWidthOriginal;
    final scaleY = containerSize.height / _svgHeightOriginal;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calcular offsets
    final scaledWidth = _svgWidthOriginal * scale;
    final scaledHeight = _svgHeightOriginal * scale;
    final offsetX = (containerSize.width - scaledWidth) / 2;
    final offsetY = (containerSize.height - scaledHeight) / 2;

    // Transformación inversa y redondear a enteros para consistencia
    final svgX = ((screenPosition.dx - offsetX) / scale).roundToDouble();
    final svgY = ((screenPosition.dy - offsetY) / scale).roundToDouble();

    return Offset(svgX, svgY);
  }

  String get rutaArchivo {
    // Asocia cada piso con su archivo SVG almacenado en la carpeta Mapas.
    switch (widget.numeroPiso) {
      case 1:
        return 'Mapas/Primer piso fac_ing simple.svg';
      case 2:
        return 'Mapas/Segundo piso fac_ing simple.svg';
      case 3:
        return 'Mapas/Tercer piso fac_ing simple.svg';
      case 4:
        return 'Mapas/Cuarto piso fac_ing simple.svg';
      default:
        return 'Mapas/Primer piso fac_ing simple.svg';
    }
  }

  String get rutaGrafoJson {
    // Asocia cada piso con su archivo JSON del grafo correspondiente.
    switch (widget.numeroPiso) {
      case 1:
        return 'lib/data/grafo_piso1.json';
      case 2:
        return 'lib/data/grafo_piso2.json';
      case 3:
        return 'lib/data/grafo_piso3.json';
      case 4:
        return 'lib/data/grafo_piso4.json';
      default:
        return 'lib/data/grafo_piso1.json';
    }
  }

  String get nombreArchivo {
    // Nombre legible del SVG para mostrarlo en mensajes al usuario.
    switch (widget.numeroPiso) {
      case 1:
        return 'Primer piso fac_ing simple';
      case 2:
        return 'Segundo piso fac_ing simple';
      case 3:
        return 'Tercer piso fac_ing simple';
      case 4:
        return 'Cuarto piso fac_ing simple';
      default:
        return 'Primer piso fac_ing simple';
    }
  }

  void _zoomIn(double scaleFactor) {
    // Delegar a la implementación genérica que aplica límites y centra el zoom.
    zoom(scaleFactor);
  }

  /// Aplica un zoom relativo respecto al centro de la pantalla.
  ///
  /// `scaleFactor` > 1.0 hace zoom-in, `scaleFactor` < 1.0 hace zoom-out.
  void zoom(double scaleFactor) {
    // Usar el mismo TransformationController que usa InteractiveViewer
    final controller = _transformationController;

    // Obtener escala actual y calcular escala objetivo respetando límites
    final currentScale = controller.value.getMaxScaleOnAxis();
    // Si la escala actual es 0 (teórica), evitar división por cero
    final double safeCurrent = currentScale <= 0 ? 1.0 : currentScale;
    final targetScale = (safeCurrent * scaleFactor).clamp(_minScale, _maxScale);
    final relativeFactor = targetScale / safeCurrent;

    // Centro actual de la vista en coordenadas de escena
    final Offset center = controller.toScene(
      Offset(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2),
    );

    // Aplicar transformación alrededor del centro
    final matrix = controller.value.clone();
    matrix
      ..translate(center.dx, center.dy)
      ..scale(relativeFactor)
      ..translate(-center.dx, -center.dy);

    controller.value = matrix;
  }

  void _resetZoom() {
    // Devuelve la vista a la transformación inicial sin desplazamientos ni zoom.
    _transformationController.value = Matrix4.identity();
  }

  void resetZoomIfNeeded() {
    final scale = _transformationController.value.getMaxScaleOnAxis();

    if (scale < _minScale) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    // Libera el controlador al cerrar la pantalla para evitar fugas de memoria.
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleNodos() {
    setState(() {
      _mostrarNodos = !_mostrarNodos;
    });
  }

  void _mostrarInfoNodo(Map<String, dynamic> nodo) {
    final String nodoId = nodo['id'] as String;
    final bool esOrigen = _origenSeleccionado == nodoId;
    final bool esDestino = _destinoSeleccionado == nodoId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              esOrigen
                  ? Icons.trip_origin
                  : esDestino
                      ? Icons.location_on
                      : Icons.place,
              color: esOrigen
                  ? Colors.green.shade600
                  : esDestino
                      ? Colors.red.shade600
                      : Colors.blue.shade600,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nodoId,
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (esOrigen)
                    Text(
                      'Origen actual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (esDestino)
                    Text(
                      'Destino actual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.info_outline, size: 20),
              title: const Text('Tipo de lugar'),
              subtitle: Text(_obtenerTipoLugar(nodoId)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.straighten, size: 20),
              title: const Text('Coordenadas'),
              subtitle: Text('X: ${nodo['x']}, Y: ${nodo['y']}'),
            ),
            if (_origenSeleccionado != null && _origenSeleccionado != nodoId)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Origen: $_origenSeleccionado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (_modoDebugActivo) // Boton para generar qr en modo debug
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generarQRParaNodoActual(nodo);
              },
              child: const Text('Generar QR'),
            ),
          // Botón para limpiar selección si es origen o destino actual
          if (esOrigen || esDestino)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarSeleccion();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Limpiar selección'),
            ),
          // Botón principal: Establecer origen o destino según el estado
          if (!esOrigen && !esDestino)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_origenSeleccionado == null) {
                  _establecerOrigen(nodoId);
                } else {
                  _establecerDestino(nodoId);
                }
              },
              child: Text(
                _origenSeleccionado == null
                    ? 'Establecer origen'
                    : 'Establecer destino',
              ),
            ),
        ],
      ),
    );
  }

  void _establecerOrigen(String nodoId) {
    setState(() {
      _origenSeleccionado = nodoId;
      _destinoSeleccionado = null;
      _rutaActiva.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.trip_origin, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Origen establecido: $nodoId\nAhora selecciona un destino'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Limpiar',
          textColor: Colors.white,
          onPressed: _limpiarSeleccion,
        ),
      ),
    );
  }

  void _establecerDestino(String nodoId) async {
    if (_origenSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes establecer un origen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (nodoId == _origenSeleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El destino debe ser diferente al origen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _destinoSeleccionado = nodoId;
    });

    // Calcular la ruta con A*
    await _calcularYMostrarRuta(_origenSeleccionado!, nodoId);
  }

  Future<void> _calcularYMostrarRuta(String origen, String destino) async {
    try {
      // Cargar el grafo del piso actual
      final String jsonString = await rootBundle.loadString(rutaGrafoJson);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final Grafo grafo = Grafo.fromJson(jsonData);

      // Ejecutar el algoritmo A*
      final resultado = AStar.calcularRuta(
        grafo: grafo,
        origen: origen,
        destino: destino,
      );

      if (resultado.isNotEmpty) {
        setState(() {
          _rutaActiva.clear();
          _rutaActiva.addAll(resultado);
        });

        final distanciaTotal = _calcularDistanciaRuta(resultado);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Ruta calculada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Desde: $origen'),
                Text('Hasta: $destino'),
                Text('Nodos: ${resultado.length}'),
                Text(
                  'Distancia: ${distanciaTotal.toStringAsFixed(1)} metros',
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Limpiar',
              textColor: Colors.white,
              onPressed: _limpiarSeleccion,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('No se encontró una ruta entre estos puntos'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
        _limpiarSeleccion();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al calcular ruta: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular la ruta: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      _limpiarSeleccion();
    }
  }

  double _calcularDistanciaRuta(List<String> ruta) {
    double distanciaTotal = 0.0;
    for (int i = 0; i < ruta.length - 1; i++) {
      final nodoActual = _nodos.firstWhere((n) => n['id'] == ruta[i]);
      final nodoSiguiente = _nodos.firstWhere((n) => n['id'] == ruta[i + 1]);

      final dx = (nodoSiguiente['x'] as num) - (nodoActual['x'] as num);
      final dy = (nodoSiguiente['y'] as num) - (nodoActual['y'] as num);
      distanciaTotal += sqrt(dx * dx + dy * dy);
    }
    return distanciaTotal;
  }

  void _limpiarSeleccion() {
    setState(() {
      _origenSeleccionado = null;
      _destinoSeleccionado = null;
      _rutaActiva.clear();
      _pasoActualRuta = 0;
      _segmentosRuta.clear();
      // _rutaActivaMultiPiso = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.clear, color: Colors.white),
            SizedBox(width: 12),
            Text('Selección limpiada'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _obtenerTipoLugar(String id) {
    if (id.contains('Entrada')) return 'Entrada principal';
    if (id.contains('Pasillo')) return 'Pasillo';
    if (id.contains('A')) return 'Aula';
    if (id.contains('Lab')) return 'Laboratorio';
    if (id.contains('Oficina')) return 'Oficina';
    if (id.contains('Baño')) return 'Baño';
    if (id.contains('Escalera')) return 'Escalera';
    if (id.contains('Ascensor')) return 'Ascensor';
    return 'Punto de interés';
  }

  IconData _obtenerIconoNodo(String id) {
    if (id.contains('Entrada')) return Icons.door_front_door;
    if (id.contains('Pasillo')) return Icons.swap_horiz;
    if (id.contains('A')) return Icons.meeting_room;
    if (id.contains('Lab')) return Icons.science;
    if (id.contains('Oficina')) return Icons.business;
    if (id.contains('Baño')) return Icons.wc;
    if (id.contains('Escalera')) return Icons.stairs;
    if (id.contains('Ascensor')) return Icons.elevator;
    return Icons.place;
  }

  // ==================== FUNCIONES NAVEGACIÓN MULTI-PISO ====================

  /// Avanza al siguiente paso en la ruta
  void _avanzarPaso() {
    if (_segmentosRuta.isEmpty) return;

    setState(() {
      // Calcular el total de pasos en todos los segmentos
      int totalPasos = 0;
      for (final segmento in _segmentosRuta) {
        totalPasos += segmento.nodos.length;
      }

      if (_pasoActualRuta < totalPasos - 1) {
        _pasoActualRuta++;

        // Verificar si necesitamos cambiar de piso
        _verificarCambioPiso();
      } else {
        // Llegó al destino
        _mostrarDialogoLlegada();
      }
    });
  }

  /// Retrocede al paso anterior en la ruta
  void _retrocederPaso() {
    if (_pasoActualRuta > 0) {
      setState(() {
        _pasoActualRuta--;
      });
    }
  }

  /// Verifica si el usuario debe cambiar de piso
  void _verificarCambioPiso() {
    int pasoActual = 0;

    for (int i = 0; i < _segmentosRuta.length; i++) {
      final segmento = _segmentosRuta[i];
      final nodosEnSegmento = segmento.nodos.length;

      // Verificar si el paso actual está en este segmento
      if (_pasoActualRuta >= pasoActual &&
          _pasoActualRuta < pasoActual + nodosEnSegmento) {
        // Verificar si es un segmento de cambio de piso
        if (segmento.tipo == TipoSegmento.escalera ||
            segmento.tipo == TipoSegmento.ascensor) {
          // Verificar si estamos en el último nodo de este segmento
          if (_pasoActualRuta == pasoActual + nodosEnSegmento - 1) {
            // Mostrar diálogo de cambio de piso
            _mostrarDialogoCambioPiso(segmento);
          }
        }
        break;
      }

      pasoActual += nodosEnSegmento;
    }
  }

  /// Muestra el diálogo cuando el usuario llega a una escalera/ascensor
  void _mostrarDialogoCambioPiso(SegmentoRuta segmento) {
    if (segmento.pisoDestino == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              segmento.tipo == TipoSegmento.escalera
                  ? Icons.stairs
                  : Icons.elevator,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Cambio de Piso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Has llegado ${segmento.tipo == TipoSegmento.escalera ? 'a la escalera' : 'al ascensor'}!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.arrow_upward,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Dirígete al Piso ${segmento.pisoDestino}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              segmento.tipo == TipoSegmento.escalera
                  ? 'Sube o baja por las escaleras'
                  : 'Toma el ascensor',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Escanea el código QR al llegar al piso ${segmento.pisoDestino} para continuar',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Cambiar al mapa del piso destino
              _cambiarAPiso(segmento.pisoDestino!);
            },
            icon: const Icon(Icons.check),
            label: Text('Ver mapa del piso ${segmento.pisoDestino}'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Cambia la vista al mapa de otro piso
  void _cambiarAPiso(int nuevoPiso) {
    // TODO: Implementar continuación de ruta en otro piso
    // Se podría pasar el nodoInicial y los segmentos restantes al nuevo PantallaMapa

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaMapa(
          numeroPiso: nuevoPiso,
          titulo: 'Piso $nuevoPiso',
        ),
      ),
    );

    // Nota: Aquí podrías pasar los segmentos restantes de la ruta
    // para que continúe la navegación en el nuevo piso
  }

  /// Muestra el diálogo de llegada al destino
  void _mostrarDialogoLlegada() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green.shade600, size: 32),
            const SizedBox(width: 12),
            const Text('¡Llegaste!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Has completado tu recorrido exitosamente.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade400,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limpiarSeleccion();
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  /// Obtiene el segmento y paso actual
  Map<String, dynamic>? _obtenerPasoActual() {
    if (_segmentosRuta.isEmpty) return null;

    int pasoAcumulado = 0;

    for (final segmento in _segmentosRuta) {
      if (_pasoActualRuta < pasoAcumulado + segmento.nodos.length) {
        final indicePaso = _pasoActualRuta - pasoAcumulado;
        final nodoId = segmento.nodos[indicePaso];

        return {
          'segmento': segmento,
          'nodoId': nodoId,
          'indicePaso': indicePaso,
        };
      }
      pasoAcumulado += segmento.nodos.length;
    }

    return null;
  }

  /// Obtiene la instrucción para el paso actual
  String _obtenerInstruccionPaso() {
    final pasoActual = _obtenerPasoActual();
    if (pasoActual == null) return '';

    final segmento = pasoActual['segmento'] as SegmentoRuta;
    final nodoId = pasoActual['nodoId'] as String;

    switch (segmento.tipo) {
      case TipoSegmento.escalera:
        return 'Dirígete a la escalera';
      case TipoSegmento.ascensor:
        return 'Dirígete al ascensor';
      case TipoSegmento.caminata:
        // Inferir instrucción basándose en el ID del nodo
        if (nodoId.contains('Entrada')) return 'Dirígete a la entrada';
        if (nodoId.contains('Pasillo')) return 'Continúa por el pasillo';
        if (nodoId.contains('Escalera')) return 'Dirígete a la escalera';
        if (nodoId.contains('Ascensor')) return 'Dirígete al ascensor';
        if (nodoId.contains('Interseccion')) return 'Gira en la intersección';
        return 'Dirígete al siguiente punto';
    }
  }

  // ==================== FIN FUNCIONES NAVEGACIÓN MULTI-PISO ====================

  // ==================== FUNCIONES DEBUG ====================

  void _toggleModoDebug() {
    setState(() {
      _modoDebugActivo = !_modoDebugActivo;
      if (!_modoDebugActivo) {
        _coordenadasDebug.clear();
        _conexionesDebug.clear();
      }
    });

    // Forzar un rebuild después del siguiente frame para recalcular posiciones correctamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Este setState vacío fuerza un rebuild con las dimensiones correctas
        });
      }
    });

    // Imprimir información de nodos cuando se activa o desactiva
    if (kDebugMode) {
      print('\n════════════════════════════════════════');
      print(_modoDebugActivo
          ? '🔧 MODO DEBUG ACTIVADO - Piso ${widget.numeroPiso}'
          : '✓ MODO DEBUG DESACTIVADO - Piso ${widget.numeroPiso}');
      print('════════════════════════════════════════');
      print('Total de nodos en el mapa: ${_nodos.length}');
      print('\nCoordenadas actuales de todos los nodos:');
      for (var i = 0; i < _nodos.length; i++) {
        final nodo = _nodos[i];
        final posEscalada = _calcularPosicionEscalada(
          (nodo['x'] as num).toDouble(),
          (nodo['y'] as num).toDouble(),
        );
        print('  [$i] ${nodo['id']}:');
        print('      SVG: x=${nodo['x']}, y=${nodo['y']}');
        print(
            '      Escalada: x=${posEscalada.dx.toInt()}, y=${posEscalada.dy.toInt()}');
      }
      if (_modoDebugActivo) {
        print('\n💡 Estado del contenedor:');
        final RenderBox? containerBox =
            _containerKey.currentContext?.findRenderObject() as RenderBox?;
        if (containerBox != null && containerBox.hasSize) {
          print(
              '   Tamaño: ${containerBox.size.width.toStringAsFixed(2)} x ${containerBox.size.height.toStringAsFixed(2)}');
          final scaleX = containerBox.size.width / _svgWidthOriginal;
          final scaleY = containerBox.size.height / _svgHeightOriginal;
          final scale = scaleX < scaleY ? scaleX : scaleY;
          print(
              '   Escala: ${scale.toStringAsFixed(4)} (scaleX: ${scaleX.toStringAsFixed(4)}, scaleY: ${scaleY.toStringAsFixed(4)})');
        } else {
          print('   ⚠️ Contenedor no disponible o sin tamaño');
        }
      }
      print('════════════════════════════════════════\n');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _modoDebugActivo
              ? '🔧 Modo Debug Activado: Toca el mapa para ver coordenadas'
              : '✓ Modo Debug Desactivado',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _modoDebugActivo ? Colors.orange : Colors.green,
      ),
    );
  }

  Future<void> _recargarNodosDesdeArchivo() async {
    try {
      if (kDebugMode) {
        print('\n${'=' * 60}');
        print('🔄 DEBUG [${DateTime.now()}]: RECARGA MANUAL DE NODOS');
        print('🔄 DEBUG: Archivo: $rutaGrafoJson');
        print('=' * 60);
      }

      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      final nodosRaw = List<Map<String, dynamic>>.from(
        data['nodos'] as List<dynamic>,
      );

      // Filtrar nodos vacíos o con datos inválidos
      final nodosNuevos = nodosRaw.where((nodo) {
        return nodo['id'] != null &&
            nodo['x'] != null &&
            nodo['y'] != null &&
            (nodo['id'] as String).isNotEmpty;
      }).toList();

      if (kDebugMode) {
        final nodosInvalidos = nodosRaw.length - nodosNuevos.length;
        print('\n✅ DEBUG: ${nodosNuevos.length} nodos válidos encontrados');
        if (nodosInvalidos > 0) {
          print('⚠️  DEBUG: $nodosInvalidos nodos inválidos filtrados');
        }
        print('-' * 60);
        for (int i = 0; i < nodosNuevos.length; i++) {
          final nodo = nodosNuevos[i];
          print(
            '${i + 1}. ${nodo['id'].toString().padRight(35)} X:${nodo['x'].toString().padLeft(4)} Y:${nodo['y'].toString().padLeft(4)}',
          );
        }
        print('-' * 60);
      }

      setState(() {
        _nodos = nodosNuevos;
        _coordenadasDebug.clear();
        _conexionesDebug.clear();
      });

      // Forzar un rebuild después del siguiente frame para recalcular posiciones correctamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            // Este setState vacío fuerza un rebuild con las dimensiones correctas
          });
        }
      });

      if (kDebugMode) {
        print('🎯 DEBUG: Estado actualizado con ${_nodos.length} nodos');
        print('🎯 DEBUG: Coordenadas debug limpiadas');
        print('${'=' * 60}\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${_nodos.length} nodos recargados desde archivo'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ DEBUG: Error al recargar: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al recargar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDebugTap(TapDownDetails details) {
    if (!_modoDebugActivo) return;

    final RenderBox? containerBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerBox == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se puede obtener el contexto del mapa'),
        ),
      );
      return;
    }

    final localPosition = containerBox.globalToLocal(details.globalPosition);

    // Convertir a coordenadas SVG
    final svgCoords = _calcularCoordenadasSVG(localPosition);
    final svgX = svgCoords.dx;
    final svgY = svgCoords.dy;

    if (kDebugMode) {
      print('\n${'=' * 60}');
      print('🎯 DEBUG TAP:');
      print(
          '📱 Screen: (${localPosition.dx.toInt()}, ${localPosition.dy.toInt()})');
      print('📐 SVG: (${svgX.toInt()}, ${svgY.toInt()})');
      print('📏 Container: ${containerBox.size}');
      print('📄 SVG Original: $_svgWidthOriginal x $_svgHeightOriginal');
      print('=' * 60);
    }

    setState(() {
      _coordenadasDebug.add({
        'x': svgX.toInt(),
        'y': svgY.toInt(),
        'timestamp': DateTime.now(),
      });
    });

    _mostrarDialogoCoordenadas(svgX, svgY);
  }

  String _generarIdNodo(TipoNodo tipo, double x, double y) {
    final prefijo = 'P${widget.numeroPiso}';
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;

    switch (tipo) {
      case TipoNodo.entrada:
        return '${prefijo}_Entrada_$timestamp';
      case TipoNodo.pasillo:
        return '${prefijo}_Pasillo_$timestamp';
      case TipoNodo.interseccion:
        return '${prefijo}_Interseccion_$timestamp';
      case TipoNodo.esquina:
        return '${prefijo}_Esquina_$timestamp';
      case TipoNodo.puerta:
        return '${prefijo}_Puerta_$timestamp';
      case TipoNodo.escalera:
        return '${prefijo}_Escalera_$timestamp';
      case TipoNodo.ascensor:
        return '${prefijo}_Ascensor_$timestamp';
      case TipoNodo.bano:
        return '${prefijo}_Bano_$timestamp';
      case TipoNodo.puntoInteres:
        return '${prefijo}_PuntoInteres_$timestamp';
    }
  }

  void _mostrarDialogoCoordenadas(double x, double y) {
    final TextEditingController idController = TextEditingController();
    TipoNodo? tipoSeleccionado;
    // Variables para la prueba de rutas dentro del diálogo
    String? origenRuta;
    String? destinoRuta;
    List<String> rutaResultado = [];
    double rutaDistancia = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.pin_drop, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Nuevo Nodo'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordenadas SVG:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        'X: ${x.toInt()}  Y: ${y.toInt()}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipo de Nodo:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TipoNodo>(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      tipoSeleccionado?.icono ?? Icons.category,
                      color: tipoSeleccionado?.color,
                    ),
                    hintText: 'Selecciona el tipo',
                  ),
                  initialValue: tipoSeleccionado,
                  items: TipoNodo.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Row(
                        children: [
                          Icon(tipo.icono, size: 20, color: tipo.color),
                          const SizedBox(width: 8),
                          Text(tipo.nombre),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value;
                      if (value != null) {
                        idController.text = _generarIdNodo(value, x, y);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'ID del nodo',
                    hintText: 'P${widget.numeroPiso}_Pasillo_1',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.label),
                    helperText: 'Se genera automáticamente al seleccionar tipo',
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                if (tipoSeleccionado != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tipoSeleccionado!.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: tipoSeleccionado!.color.withAlpha(100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tipoSeleccionado!.icono,
                          color: tipoSeleccionado!.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _obtenerDescripcionTipo(tipoSeleccionado!),
                            style: TextStyle(
                              fontSize: 12,
                              color: tipoSeleccionado!.color.withAlpha(255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Total de puntos: ${_coordenadasDebug.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // inicio sección A*
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text('Probar A* (calcular ruta)',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Construir lista segura de IDs disponibles (grafo cargado + nodos locales)
                Builder(builder: (context) {
                  // IDs disponibles: usamos los nodos ya cargados en _nodos
                  final idsSet = <String>{};
                  for (var n in _nodos) {
                    try {
                      idsSet.add(n['id'] as String);
                    } catch (e) {}
                  }

                  final ids = idsSet.toList()..sort();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Nodo Origen (A*)',
                          border: OutlineInputBorder(),
                        ),
                        items: ids.map((id) {
                          return DropdownMenuItem(value: id, child: Text(id));
                        }).toList(),
                        initialValue: origenRuta,
                        onChanged: (v) {
                          setDialogState(() {
                            origenRuta = v;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Nodo Destino (A*)',
                          border: OutlineInputBorder(),
                        ),
                        items: ids.map((id) {
                          return DropdownMenuItem(value: id, child: Text(id));
                        }).toList(),
                        initialValue: destinoRuta,
                        onChanged: (v) {
                          setDialogState(() {
                            destinoRuta = v;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: (origenRuta == null ||
                                    destinoRuta == null)
                                ? null
                                : () async {
                                    // Construir grafo temporal combinando grafo cargado y nodos/conexiones debug
                                    final nodeJsons = <Map<String, dynamic>>[];
                                    final conexs = <Map<String, dynamic>>[];

                                    // Añadir nodos desde _nodos (UI) — también serán la fuente
                                    // primaria de nodos para la prueba.
                                    for (var m in _nodos) {
                                      try {
                                        final id = m['id'] as String;
                                        final exists = nodeJsons
                                            .any((jn) => jn['id'] == id);
                                        if (!exists) {
                                          // Forzar x/y a double en caso de venir como int
                                          double x0 = 0.0;
                                          double y0 = 0.0;
                                          try {
                                            x0 = (m['x'] as num).toDouble();
                                          } catch (e) {
                                            try {
                                              x0 = double.parse(
                                                  m['x'].toString());
                                            } catch (e) {}
                                          }
                                          try {
                                            y0 = (m['y'] as num).toDouble();
                                          } catch (e) {
                                            try {
                                              y0 = double.parse(
                                                  m['y'].toString());
                                            } catch (e) {}
                                          }

                                          nodeJsons.add({
                                            'id': id,
                                            'x': x0,
                                            'y': y0,
                                          });
                                        }
                                      } catch (e) {}
                                    }

                                    // Añadir conexiones desde archivo JSON principal (si existe)
                                    try {
                                      final rawFile = await rootBundle
                                          .loadString(rutaGrafoJson);
                                      final dataFile = json.decode(rawFile)
                                          as Map<String, dynamic>;
                                      final fileConex =
                                          List<Map<String, dynamic>>.from(
                                              dataFile['conexiones']
                                                  as List<dynamic>);
                                      for (var fc in fileConex) {
                                        try {
                                          conexs.add({
                                            'origen': fc['origen'],
                                            'destino': fc['destino'],
                                            'distancia':
                                                (fc['distancia'] as num)
                                                    .toDouble(),
                                          });
                                        } catch (e) {}
                                      }
                                    } catch (e) {
                                      // archivo inexistente o sin conexiones; seguir
                                    }

                                    // Añadir conexiones debug
                                    for (var c in _conexionesDebug) {
                                      try {
                                        conexs.add({
                                          'origen': c['origen'],
                                          'destino': c['destino'],
                                          'distancia': (c['distancia'] as num)
                                              .toDouble(),
                                        });
                                      } catch (e) {}
                                    }

                                    final tempJson = {
                                      'nodos': nodeJsons,
                                      'conexiones': conexs
                                    };
                                    final tempGrafo = Grafo.fromJson(tempJson);

                                    final aStar = AStar(tempGrafo);
                                    final ruta = aStar.calcular(
                                        origen: origenRuta!,
                                        destino: destinoRuta!);

                                    double total = 0.0;
                                    final mapaAdj =
                                        tempGrafo.generarMapaAdyacencia();
                                    for (var i = 0; i < ruta.length - 1; i++) {
                                      final a = ruta[i];
                                      final b = ruta[i + 1];
                                      try {
                                        total += mapaAdj[a]![b]!;
                                      } catch (e) {}
                                    }

                                    // Imprimir resultado claro en la terminal para depuración
                                    if (kDebugMode) {
                                      // ignore: avoid_print
                                      print('\n===== A* Ruta calculada =====');
                                      // ignore: avoid_print
                                      print('Origen: ${origenRuta}');
                                      // ignore: avoid_print
                                      print('Destino: ${destinoRuta}');
                                      if (ruta.isEmpty) {
                                        // ignore: avoid_print
                                        print('Resultado: NO se encontró ruta');
                                        // ignore: avoid_print
                                        print('Posibles causas:');
                                        // ignore: avoid_print
                                        print(
                                            '- Los nodos no están conectados en el grafo.');
                                        // ignore: avoid_print
                                        print(
                                            '- Inconsistencias en los IDs entre nodos y conexiones.');
                                        // ignore: avoid_print
                                        print(
                                            '- Nodo aislado o grafo temporal incompleto.');
                                      } else {
                                        // ignore: avoid_print
                                        print('Ruta: ${ruta.join(" -> ")}');
                                        // ignore: avoid_print
                                        print(
                                            'Distancia total: ${total.toStringAsFixed(2)}');
                                      }
                                      // ignore: avoid_print
                                      print('==============================\n');
                                    }

                                    setDialogState(() {
                                      rutaResultado = ruta;
                                      rutaDistancia = total;
                                    });
                                  },
                            child: const Text('Calcular ruta A*'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      if (rutaResultado.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Ruta encontrada: ${rutaResultado.join(' → ')}'),
                              const SizedBox(height: 4),
                              Text(
                                  'Distancia total: ${rutaDistancia.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                final id = idController.text.isEmpty
                    ? 'P${widget.numeroPiso}_Nodo_${DateTime.now().millisecondsSinceEpoch % 10000}'
                    : idController.text;
                Clipboard.setData(
                  ClipboardData(
                    text: '{"id": "$id", "x": ${x.toInt()}, "y": ${y.toInt()}}',
                  ),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Coordenadas copiadas al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Copiar JSON'),
            ),
            FilledButton(
              onPressed: idController.text.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _nodos.add({
                          'id': idController.text,
                          'x': x.toInt(),
                          'y': y.toInt(),
                          'tipo': tipoSeleccionado?.name,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✓ Nodo ${idController.text} agregado',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              child: const Text('Agregar Nodo'),
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerDescripcionTipo(TipoNodo tipo) {
    switch (tipo) {
      case TipoNodo.entrada:
        return 'Entrada principal del edificio';
      case TipoNodo.pasillo:
        return 'Punto en un pasillo (cada 3-5 metros)';
      case TipoNodo.interseccion:
        return 'Cruce de dos o más pasillos';
      case TipoNodo.esquina:
        return 'Cambio de dirección en el pasillo';
      case TipoNodo.puerta:
        return 'Acceso a sala/oficina/laboratorio';
      case TipoNodo.escalera:
        return 'Conexión vertical entre pisos';
      case TipoNodo.ascensor:
        return 'Ascensor para accesibilidad';
      case TipoNodo.bano:
        return 'Servicios higiénicos';
      case TipoNodo.puntoInteres:
        return 'Lugar relevante (cafetería, biblioteca, etc.)';
    }
  }

  double _calcularDistanciaEntreNodos(String idOrigen, String idDestino) {
    final nodoOrigen = _nodos.firstWhere((nodo) => nodo['id'] == idOrigen);
    final nodoDestino = _nodos.firstWhere((nodo) => nodo['id'] == idDestino);

    final x1 = (nodoOrigen['x'] as num).toDouble();
    final y1 = (nodoOrigen['y'] as num).toDouble();
    final x2 = (nodoDestino['x'] as num).toDouble();
    final y2 = (nodoDestino['y'] as num).toDouble();

    // Distancia euclidiana
    final distancia = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));

    return distancia;
  }

  void _crearConexion() {
    if (_nodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay nodos disponibles para crear conexiones'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? origenSeleccionado;
    String? destinoSeleccionado;
    double? distanciaCalculada;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.share, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Crear Conexión'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona el nodo de origen y destino:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Dropdown para origen
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Nodo Origen',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trip_origin),
                  ),
                  initialValue: origenSeleccionado,
                  items: _nodos.map((nodo) {
                    final id = nodo['id'] as String;
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        id,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      origenSeleccionado = value;
                      if (origenSeleccionado != null &&
                          destinoSeleccionado != null) {
                        distanciaCalculada = _calcularDistanciaEntreNodos(
                          origenSeleccionado!,
                          destinoSeleccionado!,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown para destino
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Nodo Destino',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  initialValue: destinoSeleccionado,
                  items: _nodos.map((nodo) {
                    final id = nodo['id'] as String;
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        id,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      destinoSeleccionado = value;
                      if (origenSeleccionado != null &&
                          destinoSeleccionado != null) {
                        distanciaCalculada = _calcularDistanciaEntreNodos(
                          origenSeleccionado!,
                          destinoSeleccionado!,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Mostrar distancia calculada
                if (distanciaCalculada != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.straighten, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distancia calculada:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${distanciaCalculada!.toStringAsFixed(2)} píxeles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '≈ ${distanciaCalculada!.round()} unidades',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (_conexionesDebug.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conexiones creadas: ${_conexionesDebug.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (origenSeleccionado == null || destinoSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona origen y destino'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (origenSeleccionado == destinoSeleccionado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El origen y destino no pueden ser el mismo nodo',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final distancia = distanciaCalculada!.round();

                setState(() {
                  _conexionesDebug.add({
                    'origen': origenSeleccionado,
                    'destino': destinoSeleccionado,
                    'distancia': distancia,
                  });
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Conexión creada: $origenSeleccionado → $destinoSeleccionado ($distancia unidades)',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                if (kDebugMode) {
                  print('\n════════════════════════════════════════');
                  print('🔗 CONEXIÓN CREADA');
                  print('════════════════════════════════════════');
                  print('Origen: $origenSeleccionado');
                  print('Destino: $destinoSeleccionado');
                  print(
                      'Distancia calculada: ${distanciaCalculada!.toStringAsFixed(2)} píxeles');
                  print('Distancia redondeada: $distancia unidades');
                  print('Total de conexiones: ${_conexionesDebug.length}');
                  print('════════════════════════════════════════\n');
                }
              },
              child: const Text('Crear Conexión'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportarConexionesDebug() {
    if (_conexionesDebug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay conexiones para exportar')),
      );
      return;
    }

    final conexionesJson = _conexionesDebug.map((conexion) {
      return {
        'origen': conexion['origen'],
        'destino': conexion['destino'],
        'distancia': conexion['distancia'],
      };
    }).toList();

    final json = JsonEncoder.withIndent('  ').convert({
      'conexiones': conexionesJson,
    });

    Clipboard.setData(ClipboardData(text: json));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conexiones Exportadas'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Las conexiones han sido copiadas al portapapeles.',
              ),
              const SizedBox(height: 12),
              Text(
                'Total de conexiones: ${_conexionesDebug.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Agrega estas conexiones a tu archivo:'),
              Text(
                rutaGrafoJson,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _conexionesDebug.clear();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar y Cerrar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _limpiarConexionesDebug() {
    setState(() {
      _conexionesDebug.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conexiones debug limpiadas')),
    );
  }

  void _exportarCoordenadasDebug() {
    if (_coordenadasDebug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay coordenadas para exportar')),
      );
      return;
    }

    final nodosJson = _coordenadasDebug
        .asMap()
        .entries
        .map(
          (entry) => {
            'id': 'Nodo_${entry.key + 1}',
            'x': entry.value['x'],
            'y': entry.value['y'],
          },
        )
        .toList();

    // Crear guía de uso con comentarios
    final guia = '''
// ==================== GUÍA DE USO ====================
// 1. Los nodos deben seguir los pasillos transitables
// 2. Coloca nodos cada 3-5 metros en pasillos largos
// 3. Marca intersecciones donde se cruzan pasillos
// 4. Agrega puertas en cada acceso a salas
// 5. Las conexiones deben ser bidireccionales si es necesario
//
// Tipos de nodos recomendados:
// - Entrada: Accesos principales del edificio
// - Pasillo: Puntos intermedios en corredores
// - Intersección: Cruces de pasillos
// - Esquina: Cambios de dirección
// - Puerta: Acceso a salas/oficinas
// - Escalera/Ascensor: Conexiones verticales
// ====================================================

''';

    final jsonData = {'nodos': nodosJson, 'conexiones': []};
    final json = JsonEncoder.withIndent('  ').convert(jsonData);

    final exportContent = guia + json;

    Clipboard.setData(ClipboardData(text: exportContent));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON Exportado'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Las coordenadas han sido copiadas al portapapeles.'),
              const SizedBox(height: 12),
              Text(
                'Total de nodos: ${_coordenadasDebug.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Pega el contenido en tu archivo:'),
              Text(
                rutaGrafoJson,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _coordenadasDebug.clear();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar y Cerrar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _limpiarCoordenadasDebug() {
    setState(() {
      _coordenadasDebug.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coordenadas debug limpiadas')),
    );
  }

  Future<void> _migrarNodosConTipo() async {
    try {
      if (kDebugMode) {
        print('\n${'=' * 60}');
        print('🔄 MIGRACIÓN: Agregando tipos a nodos existentes');
        print('=' * 60);
      }

      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      final nodos = List<Map<String, dynamic>>.from(
        data['nodos'] as List<dynamic>,
      );
      final conexiones = data['conexiones'] as List<dynamic>;

      int nodosActualizados = 0;
      int nodosSinCambios = 0;

      // Procesar cada nodo
      final nodosConTipo = nodos.map((nodo) {
        // Saltar nodos vacíos
        if (nodo['id'] == null || (nodo['id'] as String).isEmpty) {
          return nodo;
        }

        final id = nodo['id'] as String;

        // Si ya tiene tipo, no hacer nada
        if (nodo['tipo'] != null) {
          nodosSinCambios++;
          return nodo;
        }

        // Inferir tipo por ID
        final tipoInferido = _obtenerTipoNodoPorId(id);

        if (tipoInferido != null) {
          nodosActualizados++;
          return {
            'id': nodo['id'],
            'x': nodo['x'],
            'y': nodo['y'],
            'tipo': tipoInferido.name,
          };
        }

        nodosSinCambios++;
        return nodo;
      }).toList();

      // Crear JSON actualizado con formato bonito
      final jsonActualizado = JsonEncoder.withIndent('  ').convert({
        'nodos': nodosConTipo,
        'conexiones': conexiones,
      });

      // Mostrar resultado en consola
      if (kDebugMode) {
        print('\n📊 RESULTADOS DE LA MIGRACIÓN:');
        print('   Nodos actualizados: $nodosActualizados');
        print('   Nodos sin cambios: $nodosSinCambios');
        print('   Total: ${nodos.length}');
        print('\n📋 Detalle de tipos asignados:');

        final estadisticas = <String, int>{};
        for (final nodo in nodosConTipo) {
          final tipo = nodo['tipo'] as String?;
          if (tipo != null && tipo.isNotEmpty) {
            estadisticas[tipo] = (estadisticas[tipo] ?? 0) + 1;
          }
        }

        estadisticas.forEach((tipo, cantidad) {
          try {
            final tipoEnum = TipoNodo.values.firstWhere((t) => t.name == tipo);
            print('   ${tipoEnum.nombre}: $cantidad nodos');
          } catch (e) {
            print('   $tipo: $cantidad nodos');
          }
        });

        print('\n${'=' * 60}\n');
      }

      // Copiar JSON al portapapeles
      await Clipboard.setData(ClipboardData(text: jsonActualizado));

      if (!mounted) return;

      // Mostrar diálogo con resultados
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.sync, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Migración Completada'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nodos actualizados: $nodosActualizados',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nodos sin cambios: $nodosSinCambios',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '✓ JSON actualizado copiado al portapapeles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pasos siguientes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Abre el archivo:\n   $rutaGrafoJson',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Reemplaza todo el contenido con el portapapeles',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Guarda el archivo',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  '4. Recarga los nodos en la app',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Los tipos fueron inferidos automáticamente. Revisa que sean correctos.',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Abrir visor de JSON
                _mostrarVisorJsonMigrado(jsonActualizado);
              },
              child: const Text('Ver JSON'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ $nodosActualizados nodos migrados. JSON copiado al portapapeles.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERROR en migración: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en migración: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarVisorJsonMigrado(String jsonContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON Migrado'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonContent,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copiado nuevamente')),
              );
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarEstadisticasNodos() {
    // Contar nodos por tipo
    final estadisticas = <TipoNodo, int>{};
    for (final tipo in TipoNodo.values) {
      estadisticas[tipo] = 0;
    }

    int nodosConTipo = 0;
    int nodosSinTipo = 0;

    for (final nodo in _nodos) {
      bool encontrado = false;

      // Si tiene tipo guardado
      if (nodo['tipo'] != null) {
        try {
          final tipo = TipoNodo.values.firstWhere(
            (t) => t.name == nodo['tipo'],
          );
          estadisticas[tipo] = (estadisticas[tipo] ?? 0) + 1;
          nodosConTipo++;
          encontrado = true;
        } catch (e) {
          // Continuar con inferencia
        }
      }

      // Inferir por ID
      if (!encontrado) {
        final tipoInferido = _obtenerTipoNodoPorId(nodo['id'] as String);
        if (tipoInferido != null) {
          estadisticas[tipoInferido] = (estadisticas[tipoInferido] ?? 0) + 1;
          nodosConTipo++;
        } else {
          nodosSinTipo++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text('Estadísticas de Nodos'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total de nodos: ${_nodos.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Con tipo definido: $nodosConTipo'),
              Text('Sin tipo: $nodosSinTipo'),
              const Divider(height: 24),
              const Text(
                'Distribución por tipo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...TipoNodo.values.where((tipo) {
                return (estadisticas[tipo] ?? 0) > 0;
              }).map((tipo) {
                final count = estadisticas[tipo] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(tipo.icono, size: 20, color: tipo.color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tipo.nombre)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tipo.color.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tipo.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (estadisticas.values.every((v) => v == 0))
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'No hay nodos con tipo definido aún.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recomendaciones:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Coloca nodos Pasillo cada 3-5 metros\n'
                      '• Marca Intersecciones en cruces\n'
                      '• Agrega Puertas en cada sala\n'
                      '• Usa Esquinas en cambios de dirección',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _generarQRParaNodoActual(Map<String, dynamic> nodo) {
    final qrData =
        QRUtils.generarQRParaNodo(nodo['id'] as String, widget.numeroPiso);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código QR Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Necesitarías qr_flutter para esto
            // QrImageView(data: qrData, size: 200),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              qrData,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${nodo['id']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              QRUtils.copiarQRAlPortapapeles(qrData);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR copiado al portapapeles')),
              );
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ==================== FIN FUNCIONES DEBUG ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: _modoDebugActivo
            ? Colors.orange.shade700
            : Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón Debug - Solo visible si kDebugMode está activado
          if (kDebugMode) ...[
            IconButton(
              icon: Icon(
                _modoDebugActivo ? Icons.bug_report : Icons.bug_report_outlined,
                color: _modoDebugActivo ? Colors.white : null,
              ),
              onPressed: _toggleModoDebug,
              tooltip: _modoDebugActivo
                  ? 'Desactivar modo debug'
                  : 'Activar modo debug',
            ),
            if (_modoDebugActivo) ...[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _recargarNodosDesdeArchivo,
                tooltip: 'Recargar nodos desde archivo',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Opciones Debug',
                onSelected: (value) {
                  switch (value) {
                    case 'crear_conexion':
                      _crearConexion();
                      break;
                    case 'estadisticas':
                      _mostrarEstadisticasNodos();
                      break;
                    case 'migrar_tipos':
                      _migrarNodosConTipo();
                      break;
                    case 'exportar_coordenadas':
                      _exportarCoordenadasDebug();
                      break;
                    case 'limpiar_coordenadas':
                      _limpiarCoordenadasDebug();
                      break;
                    case 'exportar_conexiones':
                      _exportarConexionesDebug();
                      break;
                    case 'limpiar_conexiones':
                      _limpiarConexionesDebug();
                      break;
                    case 'toggle_nodos':
                      _toggleNodos();
                      break;
                    case 'demo_grafo':
                      _mostrarDemoGrafo();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'crear_conexion',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 12),
                        Text('Crear Conexión'),
                      ],
                    ),
                  ),
                  if (_nodos.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'estadisticas',
                      child: Row(
                        children: [
                          Icon(Icons.analytics, size: 20),
                          SizedBox(width: 12),
                          Text('Ver Estadísticas'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'migrar_tipos',
                      child: Row(
                        children: [
                          Icon(Icons.sync, size: 20),
                          SizedBox(width: 12),
                          Text('Migrar Tipos de Nodos'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_nodos',
                      child: Row(
                        children: [
                          Icon(
                              _mostrarNodos
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20),
                          const SizedBox(width: 12),
                          Text(_mostrarNodos
                              ? 'Ocultar Nodos'
                              : 'Mostrar Nodos'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'demo_grafo',
                      child: Row(
                        children: [
                          Icon(Icons.account_tree, size: 20),
                          SizedBox(width: 12),
                          Text('Ver Demo Grafo'),
                        ],
                      ),
                    ),
                  ],
                  if (_coordenadasDebug.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'exportar_coordenadas',
                      child: Row(
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 12),
                          Text('Exportar Coordenadas'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'limpiar_coordenadas',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, size: 20),
                          SizedBox(width: 12),
                          Text('Limpiar Coordenadas'),
                        ],
                      ),
                    ),
                  ],
                  if (_conexionesDebug.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'exportar_conexiones',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 12),
                          Text('Exportar Conexiones'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'limpiar_conexiones',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, size: 20),
                          SizedBox(width: 12),
                          Text('Limpiar Conexiones'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Muestra diálogo con detalles del mapa actual.
              _mostrarInformacion(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () => _zoomIn(1.2),
          ),

          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () => zoom(0.8),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetZoom,
            tooltip: 'Reiniciar zoom',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color:
                _modoDebugActivo ? Colors.orange.shade50 : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  _modoDebugActivo ? Icons.bug_report : Icons.map,
                  color: _modoDebugActivo
                      ? Colors.orange.shade600
                      : Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _modoDebugActivo
                        ? '🔧 Debug: Toca el mapa para ver coordenadas'
                        : 'Mapa del ${widget.titulo}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _modoDebugActivo
                          ? Colors.orange.shade800
                          : Colors.blue.shade800,
                    ),
                  ),
                ),
                if (_modoDebugActivo && _coordenadasDebug.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_coordenadasDebug.length} puntos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_modoDebugActivo && _conexionesDebug.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_conexionesDebug.length} conexiones',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!_modoDebugActivo && _nodos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_nodos.length} nodos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _modoDebugActivo
                      ? 'Modo desarrollador'
                      : 'Pellizca para zoom',
                  style: TextStyle(
                    fontSize: 12,
                    color: _modoDebugActivo
                        ? Colors.orange.shade600
                        : Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true,
              scaleEnabled: true,
              minScale: _minScale,
              maxScale: _maxScale,
              boundaryMargin: EdgeInsets.all(double.infinity),
              child: GestureDetector(
                onTapDown: _modoDebugActivo ? _handleDebugTap : null,
                child: Container(
                  key: _containerKey,
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        rutaArchivo,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      // Mostrar líneas de conexiones debug
                      if (_modoDebugActivo && _conexionesDebug.isNotEmpty)
                        ..._conexionesDebug.map(
                          (conexion) => _buildConexionLinea(conexion),
                        ),
                      if (_mostrarNodos && _nodos.isNotEmpty)
                        ..._nodos.map((nodo) => _buildNodoMarker(nodo)),
                      // Mostrar marcadores de debug
                      if (_modoDebugActivo && _coordenadasDebug.isNotEmpty)
                        ..._coordenadasDebug.map(
                          (coord) => _buildDebugMarker(coord),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🆕 Barra de progreso de ruta
          _buildBarraProgresoRuta(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: () => _zoomIn(1.2),
            mini: true,
            tooltip: 'Acercar',
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () => zoom(0.8),
            mini: true,
            tooltip: 'Alejar',
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "reset_zoom",
            onPressed: _resetZoom,
            tooltip: 'Reiniciar vista',
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "qr_scanner",
            onPressed: _abrirScannerQR,
            tooltip: 'Escanear código QR',
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  void _mostrarInformacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${widget.titulo} - Información'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archivo del mapa: $nombreArchivo.svg'),
              const SizedBox(height: 12),
              const Text('Funcionalidades:'),
              const SizedBox(height: 8),
              const Text('• Navegación táctil (pan)'),
              const Text('• Zoom con pellizco'),
              const Text('• Botones de zoom'),
              const Text('• Reiniciar vista'),
              const Text('• Carga de mapas SVG'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _mostrarDiagnostico();
              },
              child: const Text('Diagnóstico'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDiagnostico() async {
    final diagnosticos = <String>[];

    // Verificar archivos SVG
    for (int i = 1; i <= 4; i++) {
      final piso = i;
      final ruta = _getRutaArchivoPorPiso(piso);
      try {
        final content = await rootBundle.loadString(ruta);
        diagnosticos.add('✓ Piso $piso: OK (${content.length} caracteres)');
      } catch (e) {
        diagnosticos.add('✗ Piso $piso: ERROR - $e');
      }
    }

    // Verificar archivos JSON del grafo
    for (int i = 1; i <= 4; i++) {
      final piso = i;
      final ruta = _getRutaGrafoPorPiso(piso);
      try {
        final content = await rootBundle.loadString(ruta);
        final data = json.decode(content);
        diagnosticos.add(
          '✓ Grafo Piso $piso: OK (${data['nodos']?.length ?? 0} nodos)',
        );
      } catch (e) {
        diagnosticos.add('✗ Grafo Piso $piso: ERROR - $e');
      }
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnóstico del Sistema'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: diagnosticos
                .map(
                  (diagnostico) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      diagnostico,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: diagnostico.startsWith('✓')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getRutaArchivoPorPiso(int piso) {
    switch (piso) {
      case 1:
        return 'Mapas/Primer piso fac_ing simple.svg';
      case 2:
        return 'Mapas/Segundo piso fac_ing simple.svg';
      case 3:
        return 'Mapas/Tercer piso fac_ing simple.svg';
      case 4:
        return 'Mapas/Cuarto piso fac_ing simple.svg';
      default:
        return 'Mapas/Primer piso fac_ing simple.svg';
    }
  }

  String _getRutaGrafoPorPiso(int piso) {
    switch (piso) {
      case 1:
        return 'lib/data/grafo_piso1.json';
      case 2:
        return 'lib/data/grafo_piso2.json';
      case 3:
        return 'lib/data/grafo_piso3.json';
      case 4:
        return 'lib/data/grafo_piso4.json';
      default:
        return 'lib/data/grafo_piso1.json';
    }
  }

  Future<void> _mostrarDemoGrafo() async {
    try {
      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      final nodos = List<Map<String, dynamic>>.from(
        data['nodos'] as List<dynamic>,
      );
      final conexiones = List<Map<String, dynamic>>.from(
        data['conexiones'] as List<dynamic>,
      );
      final ruta = _calcularRutaDemo(conexiones);

      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nodos (${nodos.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...nodos.map(
                  (nodo) => ListTile(
                    dense: true,
                    title: Text(nodo['id'] as String),
                    subtitle: Text('x: ${nodo['x']}  y: ${nodo['y']}'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Conexiones (${conexiones.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...conexiones.map(
                  (conexion) => ListTile(
                    dense: true,
                    title: Text(
                      '${conexion['origen']} → ${conexion['destino']}',
                    ),
                    subtitle: Text('Distancia: ${conexion['distancia']}'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ruta demo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (ruta.isEmpty)
                  const Text('No hay ruta de ejemplo para este piso todavía.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ruta
                        .map(
                          (paso) => Chip(
                            label: Text(paso),
                            avatar: const Icon(Icons.place, size: 16),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo cargar el grafo: $e')));
    }
  }

  List<String> _calcularRutaDemo(List<Map<String, dynamic>> conexiones) {
    if (widget.numeroPiso != 1) return [];
    const origen = 'P1_Entrada';
    const destino = 'P1_A101';
    final grafo = <String, List<String>>{};
    for (final conexion in conexiones) {
      final origenId = conexion['origen'] as String;
      final destinoId = conexion['destino'] as String;
      grafo.putIfAbsent(origenId, () => []).add(destinoId);
      grafo.putIfAbsent(destinoId, () => []).add(origenId);
    }
    final visitados = <String>{origen};
    final cola = Queue<List<String>>()..add([origen]);
    while (cola.isNotEmpty) {
      final camino = cola.removeFirst();
      final ultimo = camino.last;
      if (ultimo == destino) return camino;
      for (final vecino in grafo[ultimo] ?? const []) {
        if (visitados.add(vecino)) {
          cola.add([...camino, vecino]);
        }
      }
    }
    return [];
  }

  TipoNodo? _obtenerTipoNodoPorId(String id) {
    // Intentar inferir el tipo por el nombre del nodo
    final idLower = id.toLowerCase();

    // Entrada
    if (idLower.contains('entrada')) return TipoNodo.entrada;

    // Ascensor (debe estar antes de pasillo para evitar conflictos)
    if (idLower.contains('ascensor')) return TipoNodo.ascensor;

    // Escalera
    if (idLower.contains('escalera')) return TipoNodo.escalera;

    // Baño
    if (idLower.contains('baño') || idLower.contains('bano')) {
      return TipoNodo.bano;
    }

    // Pasillos (debe estar antes de intersección para evitar conflictos)
    if (idLower.contains('pasillo')) return TipoNodo.pasillo;

    // Intersección
    if (idLower.contains('interseccion') || idLower.contains('intersección')) {
      return TipoNodo.interseccion;
    }

    // Esquina
    if (idLower.contains('esquina')) return TipoNodo.esquina;

    // Puerta
    if (idLower.contains('puerta')) return TipoNodo.puerta;

    // Laboratorios y salas (como puntos de interés)
    if (idLower.contains('lab') ||
        idLower.contains('sala') ||
        idLower.contains('aula') ||
        idLower.contains('oficina') ||
        idLower.contains('secretaria') ||
        idLower.contains('administracion') ||
        idLower.contains('patio')) {
      return TipoNodo.puntoInteres;
    }

    // Por defecto, si no se puede identificar
    return TipoNodo.puntoInteres;
  }

  Color _obtenerColorNodo(Map<String, dynamic> nodo) {
    // Si el nodo tiene tipo guardado
    if (nodo['tipo'] != null) {
      try {
        final tipo = TipoNodo.values.firstWhere(
          (t) => t.name == nodo['tipo'],
        );
        return tipo.color;
      } catch (e) {
        // Si no se encuentra, continuar con la inferencia
      }
    }

    // Inferir por ID
    final tipoInferido = _obtenerTipoNodoPorId(nodo['id'] as String);
    if (tipoInferido != null) {
      return tipoInferido.color;
    }

    // Color por defecto
    return Colors.blue.shade500;
  }

  // ==================== Marcador de nodos ====================
  Widget _buildNodoMarker(Map<String, dynamic> nodo) {
    final x = (nodo['x'] as num).toDouble();
    final y = (nodo['y'] as num).toDouble();
    final id = nodo['id'] as String;

    // Verificar si este nodo es el origen o destino seleccionado
    final bool esOrigen = _origenSeleccionado == id;
    final bool esDestino = _destinoSeleccionado == id;

    // Obtener el color del nodo según su tipo o si es origen/destino
    final Color colorNodo;
    final IconData iconoNodo;
    final double tamano;

    if (esOrigen) {
      colorNodo = Colors.green.shade600;
      iconoNodo = Icons.trip_origin;
      tamano = 20; // Más grande para destacar
    } else if (esDestino) {
      colorNodo = Colors.red.shade600;
      iconoNodo = Icons.location_on;
      tamano = 20;
    } else {
      colorNodo = _obtenerColorNodo(nodo);
      iconoNodo = _obtenerIconoNodo(id);
      tamano = 12;
    }

    // Calcular posición escalada
    final posicionEscalada = _calcularPosicionEscalada(x, y);

    // Si estamos mostrando una ruta y este nodo está en la ruta (excepto origen/destino),
    // NO lo dibujamos para evitar tapar el mapa
    if (_rutaActiva.isNotEmpty && !esOrigen && !esDestino) {
      // Verificar si este nodo está en la ruta
      final posicionEnRuta = _rutaActiva.indexOf(id);

      // Si está en la ruta pero NO es origen (primero) ni destino (último), no mostrarlo
      if (posicionEnRuta != -1 &&
          posicionEnRuta != 0 &&
          posicionEnRuta != _rutaActiva.length - 1) {
        return const SizedBox.shrink();
      }
    }

    return Positioned(
      left: (posicionEscalada.dx - (tamano / 2)).roundToDouble(),
      top: (posicionEscalada.dy - (tamano / 2)).roundToDouble(),
      child: GestureDetector(
        onTap: () => _mostrarInfoNodo(nodo),
        child: Container(
          width: tamano,
          height: tamano,
          decoration: BoxDecoration(
            color: colorNodo,
            shape: BoxShape.circle,
            border: Border.all(
              color: (esOrigen || esDestino) ? Colors.yellow : Colors.white,
              width: (esOrigen || esDestino) ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: (esOrigen || esDestino) ? 5 : 3,
                offset: Offset(0, (esOrigen || esDestino) ? 2 : 1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              iconoNodo,
              color: Colors.white,
              size: (esOrigen || esDestino) ? 12 : 7,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Líneas de conexión debug ====================
  Widget _buildConexionLinea(Map<String, dynamic> conexion) {
    final origenId = conexion['origen'] as String;
    final destinoId = conexion['destino'] as String;

    // Buscar nodos origen y destino
    Map<String, dynamic>? nodoOrigen;
    Map<String, dynamic>? nodoDestino;

    try {
      nodoOrigen = _nodos.firstWhere((nodo) => nodo['id'] == origenId);
    } catch (e) {
      nodoOrigen = null;
    }

    try {
      nodoDestino = _nodos.firstWhere((nodo) => nodo['id'] == destinoId);
    } catch (e) {
      nodoDestino = null;
    }

    if (nodoOrigen == null || nodoDestino == null) {
      return const SizedBox.shrink();
    }

    final origenX = (nodoOrigen['x'] as num).toDouble();
    final origenY = (nodoOrigen['y'] as num).toDouble();
    final destinoX = (nodoDestino['x'] as num).toDouble();
    final destinoY = (nodoDestino['y'] as num).toDouble();

    final origenEscalado = _calcularPosicionEscalada(origenX, origenY);
    final destinoEscalado = _calcularPosicionEscalada(destinoX, destinoY);

    return CustomPaint(
      size: Size.infinite,
      painter: ConexionPainter(
        inicio: origenEscalado,
        fin: destinoEscalado,
        distancia: conexion['distancia'] as int,
      ),
    );
  }

  // ==================== Marcador del modo debug ====================
  Widget _buildDebugMarker(Map<String, dynamic> coord) {
    final x = (coord['x'] as num).toDouble();
    final y = (coord['y'] as num).toDouble();
    final timestamp = coord['timestamp'] as DateTime;

    // Calcular posición escalada
    final posicionEscalada = _calcularPosicionEscalada(x, y);

    return Positioned(
      left: (posicionEscalada.dx - 6).roundToDouble(),
      top: (posicionEscalada.dy - 6).roundToDouble(),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Punto Debug'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('X (SVG): ${x.toInt()}'),
                  Text('Y (SVG): ${y.toInt()}'),
                  const SizedBox(height: 8),
                  Text('X (Pantalla): ${posicionEscalada.dx.toInt()}'),
                  Text('Y (Pantalla): ${posicionEscalada.dy.toInt()}'),
                  const SizedBox(height: 8),
                  Text(
                    'Marcado: ${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            '{"id": "P${widget.numeroPiso}_Punto", "x": ${x.toInt()}, "y": ${y.toInt()}}',
                      ),
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coordenadas copiadas')),
                    );
                  },
                  child: const Text('Copiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.orange.shade600,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.push_pin,
              color: Colors.white,
              size: 7,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Barra de Progreso de Ruta ====================
  Widget _buildBarraProgresoRuta() {
    if (_segmentosRuta.isEmpty) return const SizedBox.shrink();

    final pasoActual = _obtenerPasoActual();
    if (pasoActual == null) return const SizedBox.shrink();

    final segmento = pasoActual['segmento'] as SegmentoRuta;
    final nodoId = pasoActual['nodoId'] as String;
    final esConexionVertical = segmento.tipo == TipoSegmento.escalera ||
        segmento.tipo == TipoSegmento.ascensor;

    // Calcular total de pasos
    int totalPasos = 0;
    for (final seg in _segmentosRuta) {
      totalPasos += seg.nodos.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esConexionVertical ? Colors.orange.shade50 : Colors.blue.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progreso
          Row(
            children: [
              Text(
                'Paso ${_pasoActualRuta + 1} de $totalPasos',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${((_pasoActualRuta / totalPasos) * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _pasoActualRuta / totalPasos,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              esConexionVertical ? Colors.orange : Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Instrucción actual
          Row(
            children: [
              Icon(
                _obtenerIconoNodo(nodoId),
                size: 32,
                color: esConexionVertical ? Colors.orange : Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _obtenerInstruccionPaso(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nodoId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasoActualRuta > 0 ? _retrocederPaso : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _avanzarPaso,
                  icon: const Icon(Icons.check),
                  label: Text(
                    _pasoActualRuta == totalPasos - 1
                        ? '¡Llegué!'
                        : 'Siguiente',
                  ),
                ),
              ),
            ],
          ),

          // Botón especial para escanear QR en escaleras/ascensores
          if (esConexionVertical) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _abrirScannerQR,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear QR para confirmar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== Custom Painter para dibujar conexiones ====================
class ConexionPainter extends CustomPainter {
  final Offset inicio;
  final Offset fin;
  final int distancia;

  ConexionPainter({
    required this.inicio,
    required this.fin,
    required this.distancia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade600.withAlpha((0.7 * 255).round())
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar línea
    canvas.drawLine(inicio, fin, paint);

    // Dibujar flecha en el destino
    final angle = (fin - inicio).direction;
    final arrowSize = 8.0;

    final arrowPath = Path();
    arrowPath.moveTo(
      fin.dx - arrowSize * cos(angle - 0.4),
      fin.dy - arrowSize * sin(angle - 0.4),
    );
    arrowPath.lineTo(fin.dx, fin.dy);
    arrowPath.lineTo(
      fin.dx - arrowSize * cos(angle + 0.4),
      fin.dy - arrowSize * sin(angle + 0.4),
    );

    final arrowPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);

    // Dibujar distancia en el centro de la línea
    final center = Offset(
      (inicio.dx + fin.dx) / 2,
      (inicio.dy + fin.dy) / 2,
    );

    final textSpan = TextSpan(
      text: '${distancia}m',
      style: TextStyle(
        color: Colors.green.shade800,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.white.withAlpha((0.9 * 255).round()),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ConexionPainter oldDelegate) {
    return oldDelegate.inicio != inicio ||
        oldDelegate.fin != fin ||
        oldDelegate.distancia != distancia;
  }
}
