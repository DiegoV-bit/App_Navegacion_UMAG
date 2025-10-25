import 'package:flutter/material.dart';

void main() {
  runApp(const NavigacionUMAGApp());
}

class NavigacionUMAGApp extends StatelessWidget {
  const NavigacionUMAGApp({super.key});

  @override
  Widget build(BuildContext context) {
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
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
  String get nombreArchivo {
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
              _mostrarInformacion(context);
            },
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
                Text(
                  'Mapa del ${widget.titulo}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey.shade100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mapa: $nombreArchivo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El mapa se cargará aquí',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
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
            onPressed: () {
              // Implementar zoom in
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Zoom In')));
            },
            mini: true,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () {
              // Implementar zoom out
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Zoom Out')));
            },
            mini: true,
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "location",
            onPressed: () {
              // Implementar ubicación actual
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Centrar mapa')));
            },
            child: const Icon(Icons.my_location),
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
              Text('Archivo del mapa: $nombreArchivo'),
              const SizedBox(height: 12),
              const Text('Funcionalidades:'),
              const SizedBox(height: 8),
              const Text('• Navegación táctil (pan)'),
              const Text('• Zoom con gestos'),
              const Text('• Botones de zoom'),
              const Text('• Centrar mapa'),
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
