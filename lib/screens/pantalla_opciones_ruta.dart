import 'package:flutter/material.dart';

/// Pantalla que muestra las diferentes opciones de ruta al usuario
class PantallaOpcionesRuta extends StatelessWidget {
  final List<OpcionRuta> opciones;
  final String origenNombre;
  final String destinoNombre;

  const PantallaOpcionesRuta({
    super.key,
    required this.opciones,
    required this.origenNombre,
    required this.destinoNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu ruta'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Encabezado con origen y destino
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trip_origin,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Origen: $origenNombre',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Destino: $destinoNombre',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de opciones
          Expanded(
            child: opciones.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron rutas disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: opciones.length,
                    itemBuilder: (context, index) {
                      final opcion = opciones[index];
                      return _buildOpcionCard(context, opcion, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionCard(BuildContext context, OpcionRuta opcion, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.pop(context, opcion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la opción
              Row(
                children: [
                  Icon(
                    _getIconoOpcion(opcion),
                    size: 32,
                    color: _getColorOpcion(opcion),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opción ${index + 1}: ${opcion.descripcion}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${opcion.distanciaTotal.toStringAsFixed(1)} m',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatearTiempo(opcion.tiempoEstimado),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Pasos de la ruta
              _buildSegmentos(opcion.segmentos),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentos(List<SegmentoRuta> segmentos) {
    return Column(
      children: segmentos.asMap().entries.map((entry) {
        final index = entry.key;
        final segmento = entry.value;

        return Column(
          children: [
            if (index > 0) _buildFlecha(),
            _buildSegmentoItem(segmento, index),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSegmentoItem(SegmentoRuta segmento, int index) {
    IconData icono;
    String texto;
    Color color;

    switch (segmento.tipo) {
      case TipoSegmento.caminata:
        icono = Icons.directions_walk;
        texto =
            'Caminar ${segmento.distancia.toStringAsFixed(0)}m en Piso ${segmento.piso}';
        color = Colors.green;
        break;
      case TipoSegmento.escalera:
        icono = Icons.stairs;
        texto = 'Subir/bajar por escalera al Piso ${segmento.pisoDestino}';
        color = Colors.orange;
        break;
      case TipoSegmento.ascensor:
        icono = Icons.elevator;
        texto = 'Tomar ascensor al Piso ${segmento.pisoDestino}';
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texto,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (segmento.nodos.length > 2)
                  Text(
                    '${segmento.nodos.length} puntos',
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlecha() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(
            Icons.arrow_downward,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  IconData _getIconoOpcion(OpcionRuta opcion) {
    if (opcion.tipo == null) return Icons.directions_walk;
    return opcion.tipo == TipoConexionVertical.escalera
        ? Icons.stairs
        : Icons.elevator;
  }

  Color _getColorOpcion(OpcionRuta opcion) {
    if (opcion.tipo == null) return Colors.green;
    return opcion.tipo == TipoConexionVertical.escalera
        ? Colors.orange
        : Colors.blue;
  }

  String _formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    if (minutos > 0) {
      return '$minutos min${segs > 0 ? " $segs seg" : ""}';
    }
    return '$segs seg';
  }
}
