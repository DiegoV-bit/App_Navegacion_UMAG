import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' show Vector3;

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
                      size: 80,
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
  late Future<void> _svgFuture = Future.value();
  List<Map<String, dynamic>> _nodos = [];
  bool _mostrarNodos = true;

  @override
  void initState() {
    super.initState();
    _svgFuture = _precargarSvg();
    _cargarNodos();
  }

  Future<void> _cargarNodos() async {
    try {
      final raw = await rootBundle.loadString(rutaGrafoJson);
      final data = json.decode(raw) as Map<String, dynamic>;
      setState(() {
        _nodos =
            List<Map<String, dynamic>>.from(data['nodos'] as List<dynamic>);
      });
    } catch (e) {
      // Manejo de errores al cargar nodos
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los nodos: $e')),
      );
    }
  }

  Future<void> _precargarSvg() async {
    // Precarga el SVG para evitar demoras en la UI
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _cargarYValidarSvg() async {
    try {
      // Intenta cargar el string del asset para validar que existe
      final content = await rootBundle.loadString(rutaArchivo);
      if (content.isEmpty) {
        throw Exception('El archivo SVG está vacío');
      }
      // Validación básica de que es un SVG
      if (!content.trim().startsWith('<svg') && !content.contains('<svg')) {
        throw Exception('El archivo no parece ser un SVG válido');
      }
    } catch (e) {
      throw Exception(
          'No se pudo cargar el archivo SVG: $rutaArchivo. Error: $e');
    }
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
            Icon(Icons.location_on, color: Colors.blue.shade600),
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
              leading: const Icon(Icons.info_outline),
              title: const Text('Tipo de lugar'),
              subtitle: Text(_obtenerTipoLugar(nodo['id'] as String)),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.straighten),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.map, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mapa del ${widget.titulo}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                if (_nodos.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  'Pellizca para zoom',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _svgFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando mapa...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar el mapa',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Archivo: $nombreArchivo.svg',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.3,
                  maxScale: 4.0,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Stack(
                      children: [
                        FutureBuilder(
                          future: _cargarYValidarSvg(),
                          builder: (context, svgSnapshot) {
                            if (svgSnapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.orange.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No se pudo cargar el mapa SVG',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Archivo: $rutaArchivo',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error: ${svgSnapshot.error}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _svgFuture = _precargarSvg();
                                        });
                                      },
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SvgPicture.asset(
                              rutaArchivo,
                              fit: BoxFit.contain,
                              placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        if (_mostrarNodos && _nodos.isNotEmpty)
                          ..._nodos.map((nodo) => _buildNodoMarker(nodo)),
                      ],
                    ),
                  ),
                );
              },
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
            '✓ Grafo Piso $piso: OK (${data['nodos']?.length ?? 0} nodos)');
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
                .map((diagnostico) => Padding(
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
                    ))
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
      final nodos =
          List<Map<String, dynamic>>.from(data['nodos'] as List<dynamic>);
      final conexiones =
          List<Map<String, dynamic>>.from(data['conexiones'] as List<dynamic>);
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
                Text('Nodos (${nodos.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...nodos.map(
                  (nodo) => ListTile(
                    dense: true,
                    title: Text(nodo['id'] as String),
                    subtitle: Text('x: ${nodo['x']}  y: ${nodo['y']}'),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Conexiones (${conexiones.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...conexiones.map(
                  (conexion) => ListTile(
                    dense: true,
                    title:
                        Text('${conexion['origen']} → ${conexion['destino']}'),
                    subtitle: Text('Distancia: ${conexion['distancia']}'),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Ruta demo',
                    style: Theme.of(context).textTheme.titleMedium),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el grafo: $e')),
      );
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

  Widget _buildNodoMarker(Map<String, dynamic> nodo) {
    final x = (nodo['x'] as num).toDouble();
    final y = (nodo['y'] as num).toDouble();
    final id = nodo['id'] as String;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => _mostrarInfoNodo(nodo),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade500,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _obtenerIconoNodo(id),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
