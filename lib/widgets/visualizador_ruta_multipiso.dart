import 'package:flutter/material.dart';
import '../models/grafo_multipiso.dart';
import '../utils/a_estrella_multipiso.dart';

/// Widget que muestra las instrucciones de navegación multi-piso
class VisualizadorRutaMultiPiso extends StatelessWidget {
  final ResultadoRutaMultiPiso resultado;
  final GrafoMultiPiso grafoMultiPiso;
  final VoidCallback? onCerrar;
  final Function(int)? onCambiarPiso;

  const VisualizadorRutaMultiPiso({
    super.key,
    required this.resultado,
    required this.grafoMultiPiso,
    this.onCerrar,
    this.onCambiarPiso,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Instrucciones de Navegación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCerrar,
                ),
              ],
            ),
            const Divider(),
            _buildResumen(),
            const SizedBox(height: 16),
            const Text(
              'Ruta por Piso:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildInstruccionesPorPiso(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    final pisosInvolucrados = resultado.rutaPorPiso.keys.toList()..sort();

    return Container(
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
              const Icon(Icons.route, size: 20),
              const SizedBox(width: 8),
              Text('${resultado.ruta.length} pasos'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.straighten, size: 20),
              const SizedBox(width: 8),
              Text('${resultado.distanciaTotal.toStringAsFixed(1)} unidades'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.layers, size: 20),
              const SizedBox(width: 8),
              Text('Pisos: ${pisosInvolucrados.join(" → ")}'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInstruccionesPorPiso() {
    final widgets = <Widget>[];
    final pisosOrdenados = resultado.rutaPorPiso.keys.toList()..sort();

    for (int i = 0; i < pisosOrdenados.length; i++) {
      final piso = pisosOrdenados[i];
      final nodosPiso = resultado.rutaPorPiso[piso]!;

      widgets.add(
        Card(
          color: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              child: Text('P$piso'),
            ),
            title: Text('Piso $piso'),
            subtitle: Text('${nodosPiso.length} nodos'),
            trailing: onCambiarPiso != null
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('Ver'),
                    onPressed: () => onCambiarPiso!(piso),
                  )
                : null,
          ),
        ),
      );

      // Mostrar transición si no es el último piso
      if (i < pisosOrdenados.length - 1) {
        final siguientePiso = pisosOrdenados[i + 1];
        final esSubida = siguientePiso > piso;

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Icon(
                  esSubida ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  esSubida
                      ? 'Subir al piso $siguientePiso'
                      : 'Bajar al piso $siguientePiso',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
