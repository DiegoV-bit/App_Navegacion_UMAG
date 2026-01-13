import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grafo.dart';
import '../models/nodo.dart';
import 'a_estrella.dart';

/// Pantalla para seleccionar el destino de navegación después de escanear un QR.
///
/// Esta pantalla proporciona:
/// - Información sobre la ubicación actual (origen)
/// - Dropdown con todos los destinos disponibles del mismo piso
/// - Cálculo automático de ruta al seleccionar destino
/// - Visualización detallada de la ruta calculada
/// - Botón para iniciar navegación con la ruta
///
/// Flujo de uso:
/// 1. Usuario escanea QR que identifica su ubicación
/// 2. Se abre esta pantalla mostrando la ubicación actual
/// 3. Usuario selecciona destino del dropdown
/// 4. Se calcula y muestra la ruta automáticamente
/// 5. Usuario confirma e inicia navegación
///
/// Ejemplo:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => PantallaSeleccionDestino(
///       nodoOrigenId: 'P1_Entrada_1',
///       pisoActual: 1,
///       grafo: grafo,
///     ),
///   ),
/// );
/// ```
class PantallaSeleccionDestino extends StatefulWidget {
  /// ID del nodo de origen (ubicación actual del usuario)
  final String nodoOrigenId;

  /// Número del piso actual (1-4)
  final int pisoActual;

  /// Grafo del piso con todos los nodos y conexiones
  final Grafo grafo;

  const PantallaSeleccionDestino({
    super.key,
    required this.nodoOrigenId,
    required this.pisoActual,
    required this.grafo,
  });

  @override
  State<PantallaSeleccionDestino> createState() =>
      _PantallaSeleccionDestinoState();
}

/// Estado de la pantalla de selección de destino.
class _PantallaSeleccionDestinoState extends State<PantallaSeleccionDestino> {
  /// ID del nodo de destino seleccionado por el usuario
  String? _nodoDestinoSeleccionado;

  /// Indica si se está calculando una ruta actualmente
  bool _calculandoRuta = false;

  /// Lista de IDs de nodos que forman la ruta calculada
  List<String>? _rutaCalculada;

  /// Distancia total de la ruta en unidades del mapa SVG
  double? _distanciaTotal;

  @override
  Widget build(BuildContext context) {
    final nodoOrigen = widget.grafo.nodos.firstWhere(
      (n) => n.id == widget.nodoOrigenId,
      orElse: () => Nodo(
        id: widget.nodoOrigenId,
        x: 0,
        y: 0,
      ),
    );

    // Filtrar nodos del mismo piso y excluir el origen
    final nodosDisponibles = widget.grafo.nodos.where((nodo) {
      final pisoNodo = _extraerPiso(nodo.id);
      return pisoNodo == widget.pisoActual && nodo.id != widget.nodoOrigenId;
    }).toList();

    // Ordenar por nombre para mejor UX
    nodosDisponibles.sort((a, b) =>
        _obtenerNombreAmigable(a.id).compareTo(_obtenerNombreAmigable(b.id)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Destino'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con información del origen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📍 Ubicación Actual',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _obtenerNombreAmigable(nodoOrigen.id),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Piso ${widget.pisoActual}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '🎯 ¿A dónde deseas ir?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown de destinos
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'Selecciona tu destino',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _nodoDestinoSeleccionado,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: nodosDisponibles.map((nodo) {
                          return DropdownMenuItem<String>(
                            value: nodo.id,
                            child: Row(
                              children: [
                                Icon(
                                  _obtenerIconoParaNodo(nodo.id),
                                  size: 20,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _obtenerNombreAmigable(nodo.id),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? nuevoDestino) {
                          setState(() {
                            _nodoDestinoSeleccionado = nuevoDestino;
                            _rutaCalculada = null;
                            _distanciaTotal = null;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de calcular ruta
                  if (_nodoDestinoSeleccionado != null && !_calculandoRuta)
                    ElevatedButton.icon(
                      onPressed: _calcularRuta,
                      icon: const Icon(Icons.route),
                      label: const Text(
                        'Calcular Ruta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  // Indicador de carga
                  if (_calculandoRuta)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Calculando ruta óptima...'),
                          ],
                        ),
                      ),
                    ),

                  // Resultado de la ruta
                  if (_rutaCalculada != null && !_calculandoRuta)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.green[900]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[700]!
                                    : Colors.green[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ruta Encontrada',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_distanciaTotal != null)
                              Text(
                                '📏 Distancia: ${_distanciaTotal!.toStringAsFixed(1)} unidades',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            Text(
                              '👣 Pasos: ${_rutaCalculada!.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Recorrido:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _rutaCalculada!.length,
                                itemBuilder: (context, index) {
                                  final nodoId = _rutaCalculada![index];
                                  final esOrigen = index == 0;
                                  final esDestino =
                                      index == _rutaCalculada!.length - 1;

                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: esOrigen
                                          ? Colors.green
                                          : esDestino
                                              ? Colors.red
                                              : Colors.blue,
                                      radius: 14,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      _obtenerNombreAmigable(nodoId),
                                      style: TextStyle(
                                        fontWeight: esOrigen || esDestino
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: Icon(
                                      esOrigen
                                          ? Icons.flag
                                          : esDestino
                                              ? Icons.location_on
                                              : Icons.circle,
                                      size: esOrigen || esDestino ? 18 : 8,
                                      color: esOrigen
                                          ? Colors.green
                                          : esDestino
                                              ? Colors.red
                                              : Colors.blue[300],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Botón de iniciar navegación (solo si hay ruta)
          if (_rutaCalculada != null && !_calculandoRuta)
            Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () => _iniciarNavegacion(),
                icon: const Icon(Icons.navigation),
                label: const Text(
                  'Iniciar Navegación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Calcula la ruta óptima entre origen y destino usando el algoritmo A*.
  ///
  /// Este método:
  /// 1. Valida que haya un destino seleccionado
  /// 2. Usa el algoritmo A* para encontrar el camino óptimo
  /// 3. Calcula la distancia total sumando distancias euclidianas entre nodos consecutivos
  /// 4. Actualiza el estado con la ruta y distancia calculadas
  /// 5. Muestra errores si no se encuentra ruta
  ///
  /// Maneja el estado de carga ([_calculandoRuta]) para mostrar indicadores visuales.
  void _calcularRuta() async {
    if (_nodoDestinoSeleccionado == null) return;

    setState(() {
      _calculandoRuta = true;
      _rutaCalculada = null;
      _distanciaTotal = null;
    });

    try {
      // Calcular ruta con A*
      final ruta = AStar.calcularRuta(
        grafo: widget.grafo,
        origen: widget.nodoOrigenId,
        destino: _nodoDestinoSeleccionado!,
      );

      if (ruta.isEmpty) {
        _mostrarError('No se encontró una ruta entre estos puntos');
        setState(() {
          _calculandoRuta = false;
        });
        return;
      }

      // Calcular distancia total
      double distancia = 0;
      for (int i = 0; i < ruta.length - 1; i++) {
        final nodo1 = widget.grafo.nodos.firstWhere((n) => n.id == ruta[i]);
        final nodo2 = widget.grafo.nodos.firstWhere((n) => n.id == ruta[i + 1]);
        final dx = nodo1.x - nodo2.x;
        final dy = nodo1.y - nodo2.y;
        distancia += sqrt(dx * dx + dy * dy);
      }

      setState(() {
        _rutaCalculada = ruta;
        _distanciaTotal = distancia;
        _calculandoRuta = false;
      });
    } catch (e) {
      _mostrarError('Error al calcular la ruta: $e');
      setState(() {
        _calculandoRuta = false;
      });
    }
  }

  /// Inicia la navegación con la ruta calculada.
  ///
  /// Retorna al scanner (que a su vez retorna al mapa) con la información de la ruta:
  /// - Lista de nodos de la ruta
  /// - ID de origen y destino
  /// - Distancia total
  ///
  /// El mapa usará esta información para visualizar la ruta.
  void _iniciarNavegacion() {
    if (_rutaCalculada == null) return;

    // Retornar la ruta al scanner (que luego la pasará al mapa)
    Navigator.pop(context, {
      'ruta': _rutaCalculada,
      'origen': widget.nodoOrigenId,
      'destino': _nodoDestinoSeleccionado,
      'distancia': _distanciaTotal,
    });
  }

  /// Muestra un mensaje de error al usuario.
  ///
  /// Parámetros:
  /// - [mensaje]: Texto del error a mostrar
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Extrae el número de piso del ID de un nodo.
  ///
  /// Parámetros:
  /// - [nodoId]: ID del nodo (formato: "P{piso}_{nombre}")
  ///
  /// Retorna:
  /// - Número de piso extraído
  /// - [pisoActual] si no se puede extraer
  ///
  /// Ejemplo:
  /// ```dart
  /// _extraerPiso('P1_Entrada_1'); // Retorna 1
  /// _extraerPiso('P3_Lab_Fisica'); // Retorna 3
  /// ```
  int _extraerPiso(String nodoId) {
    // Extraer el número del piso del ID (ej: P1_Entrada_1 -> 1)
    if (nodoId.startsWith('P') && nodoId.contains('_')) {
      try {
        final pisoStr = nodoId.split('_')[0].substring(1);
        return int.parse(pisoStr);
      } catch (e) {
        return widget.pisoActual;
      }
    }
    return widget.pisoActual;
  }

  /// Convierte un ID técnico de nodo a un nombre legible para el usuario.
  ///
  /// Transforma IDs como "P1_Entrada_1" en "Entrada 1"
  /// y "P2_Aula_A201" en "Aula A201".
  ///
  /// Parámetros:
  /// - [nodoId]: ID técnico del nodo
  ///
  /// Retorna:
  /// - Nombre formateado y legible
  /// - El ID original si no se puede formatear
  String _obtenerNombreAmigable(String nodoId) {
    // Convertir ID técnico a nombre legible
    // P1_Entrada_1 -> Entrada 1
    // P2_Aula_A201 -> Aula A201
    if (nodoId.contains('_')) {
      final partes = nodoId.split('_');
      if (partes.length >= 2) {
        final tipo = partes[1].replaceAll('_', ' ');
        if (partes.length > 2) {
          final detalle = partes.skip(2).join(' ');
          return '$tipo $detalle';
        }
        return tipo;
      }
    }
    return nodoId;
  }

  /// Obtiene un icono apropiado para un nodo según su tipo o nombre.
  ///
  /// Analiza el ID del nodo y retorna un icono Material que represente
  /// el tipo de ubicación (entrada, aula, laboratorio, etc.).
  ///
  /// Parámetros:
  /// - [nodoId]: ID del nodo
  ///
  /// Retorna:
  /// - [IconData] apropiado para el tipo de nodo
  /// - [Icons.place] como icono por defecto
  IconData _obtenerIconoParaNodo(String nodoId) {
    final id = nodoId.toLowerCase();
    if (id.contains('entrada')) return Icons.door_front_door;
    if (id.contains('pasillo')) return Icons.swap_horiz;
    if (id.contains('aula') || id.contains('sala')) return Icons.meeting_room;
    if (id.contains('lab')) return Icons.science;
    if (id.contains('oficina')) return Icons.business;
    if (id.contains('baño') || id.contains('bano')) return Icons.wc;
    if (id.contains('escalera')) return Icons.stairs;
    if (id.contains('ascensor')) return Icons.elevator;
    if (id.contains('patio')) return Icons.park;
    if (id.contains('biblioteca')) return Icons.local_library;
    if (id.contains('cafeteria')) return Icons.restaurant;
    return Icons.place;
  }
}
