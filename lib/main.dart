import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;

// ==================== CONFIGURACIÓN DEBUG ====================
// Cambiar a false cuando la aplicación esté lista para producción
const bool kDebugMode = true;
// =============================================================

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
                      'Laboratorios de la Facultad',
                      Icons.science,
                      Colors.green,
                      1,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Segundo Piso',
                      'Aulas y oficinas',
                      Icons.school,
                      Colors.orange,
                      2,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Tercer Piso',
                      'Salas de estudio',
                      Icons.book,
                      Colors.purple,
                      3,
                    ),
                    const SizedBox(height: 12),
                    _buildPisoCard(
                      context,
                      'Cuarto Piso',
                      'Administración',
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

  @override
  void initState() {
    super.initState();
    _configurarDimensionesSVG();
    _inicializarMapa();
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
      _nodos = List<Map<String, dynamic>>.from(data['nodos'] as List<dynamic>);

      if (kDebugMode) {
        print('\n════════════════════════════════════════');
        print('📍 CARGA DE NODOS - Piso ${widget.numeroPiso}');
        print('════════════════════════════════════════');
        print('Total de nodos: ${_nodos.length}');
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

  void _zoomIn() {
    // Amplía la vista actual multiplicando la matriz de transformación.
    final Matrix4 matrix = _transformationController.value.clone();
    // Usar `scaleByVector3` para aplicar la escala (evita el método deprecado `scale`).
    matrix.scaleByVector3(Vector3(1.2, 1.2, 1.0));
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    // Reduce la vista actual aplicando una escala menor.
    final Matrix4 matrix = _transformationController.value.clone();
    // Reemplazo similar para reducir escala usando Vector3.
    matrix.scaleByVector3(Vector3(0.8, 0.8, 1.0));
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    // Devuelve la vista a la transformación inicial sin desplazamientos ni zoom.
    _transformationController.value = Matrix4.identity();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue.shade600, size: 5),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nodo['id'] as String,
                style: const TextStyle(fontSize: 18),
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
              leading: const Icon(Icons.info_outline, size: 5),
              title: const Text('Tipo de lugar'),
              subtitle: Text(_obtenerTipoLugar(nodo['id'] as String)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.straighten, size: 5),
              title: const Text('Coordenadas'),
              subtitle: Text('X: ${nodo['x']}, Y: ${nodo['y']}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navegando a ${nodo['id']}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Navegar aquí'),
          ),
        ],
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
      final nodosNuevos = List<Map<String, dynamic>>.from(
        data['nodos'] as List<dynamic>,
      );

      if (kDebugMode) {
        print('\n✅ DEBUG: ${nodosNuevos.length} nodos encontrados:');
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

  void _mostrarDialogoCoordenadas(double x, double y) {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pin_drop, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Coordenadas del Mapa'),
          ],
        ),
        content: Column(
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
                    'X: ${x.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  SelectableText(
                    'Y: ${y.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'ID del nodo (opcional)',
                hintText: 'Ej: P${widget.numeroPiso}_A101',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total de puntos marcados: ${_coordenadasDebug.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '{"id": "${idController.text}", "x": ${x.toInt()}, "y": ${y.toInt()}}',
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
          if (idController.text.isNotEmpty)
            FilledButton(
              onPressed: () {
                setState(() {
                  _nodos.add({
                    'id': idController.text,
                    'x': x.toInt(),
                    'y': y.toInt(),
                  });
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Nodo ${idController.text} agregado temporalmente',
                    ),
                  ),
                );
              },
              child: const Text('Agregar Nodo'),
            ),
        ],
      ),
    );
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

    final json = JsonEncoder.withIndent(
      '  ',
    ).convert({'nodos': nodosJson, 'conexiones': []});

    Clipboard.setData(ClipboardData(text: json));

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
            icon: Icon(_mostrarNodos ? Icons.visibility : Icons.visibility_off),
            onPressed: _toggleNodos,
            tooltip: _mostrarNodos ? 'Ocultar nodos' : 'Mostrar nodos',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Muestra diálogo con detalles del mapa actual.
              _mostrarInformacion(context);
            },
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
              minScale: 0.3,
              maxScale: 4.0,
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
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: _zoomIn,
            mini: true,
            tooltip: 'Acercar',
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: _zoomOut,
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
            heroTag: "graph_demo",
            onPressed: _mostrarDemoGrafo,
            tooltip: 'Ver grafo',
            child: const Icon(Icons.route),
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

  // ==================== Marcador de nodos ====================
  Widget _buildNodoMarker(Map<String, dynamic> nodo) {
    final x = (nodo['x'] as num).toDouble();
    final y = (nodo['y'] as num).toDouble();
    final id = nodo['id'] as String;

    // Calcular posición escalada
    final posicionEscalada = _calcularPosicionEscalada(x, y);

    return Positioned(
      left: (posicionEscalada.dx - 6).roundToDouble(),
      top: (posicionEscalada.dy - 6).roundToDouble(),
      child: GestureDetector(
        onTap: () => _mostrarInfoNodo(nodo),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.blue.shade500,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Icon(_obtenerIconoNodo(id), color: Colors.white, size: 7),
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
