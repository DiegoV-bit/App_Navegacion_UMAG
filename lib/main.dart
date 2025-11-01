import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  color: color.withOpacity(0.1),
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

  String get rutaArchivo {
    // Asocia cada piso con su archivo SVG almacenado en la carpeta Mapas.
    switch (widget.numeroPiso) {
      case 1:
        return 'Mapas/Primer piso labs_fac_ing simple.svg';
      case 2:
        return 'Mapas/Segundo piso fac ing simple.svg';
      case 3:
        return 'Mapas/Tercer piso fac_ing simple.svg';
      case 4:
        return 'Mapas/Cuarto piso fac_ing simple.svg';
      default:
        return 'Mapas/Primer piso labs_fac_ing simple.svg';
    }
  }

  String get nombreArchivo {
    // Nombre legible del SVG para mostrarlo en mensajes al usuario.
    switch (widget.numeroPiso) {
      case 1:
        return 'Primer piso labs_fac_ing simple';
      case 2:
        return 'Segundo piso fac ing simple';
      case 3:
        return 'Tercer piso fac_ing simple';
      case 4:
        return 'Cuarto piso fac_ing simple';
      default:
        return 'Primer piso labs_fac_ing simple';
    }
  }

  void _zoomIn() {
    // Amplía la vista actual multiplicando la matriz de transformación.
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(1.2);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    // Reduce la vista actual aplicando una escala menor.
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(0.8);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.3,
              maxScale: 5.0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: FutureBuilder(
                  future: _loadSvg(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Muestra indicador de carga hasta que el mapa esté disponible.
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
                      // Diagnóstico amigable cuando el archivo no se encuentra o falla al cargar.
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

                    return Center(
                      // Muestra el SVG dentro del visor con ajuste proporcional.
                      child: SvgPicture.asset(
                        rutaArchivo,
                        fit: BoxFit.contain,
                        placeholderBuilder: (BuildContext context) => Container(
                          padding: const EdgeInsets.all(30.0),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    );
                  },
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
        ],
      ),
    );
  }

  Future<void> _loadSvg() async {
    // Simula una breve espera para que el indicador de carga sea visible.
    await Future.delayed(const Duration(milliseconds: 500));
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
