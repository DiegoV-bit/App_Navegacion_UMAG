# Modelado del grafo de salas y conexiones
La aplicacion hace uso de un modelo de grafo para poder representar la topologia de cada piso del edificio (dicho de otra forma se representa mediante el grafo las salas de clase, oficinas y laboratorio de toda la facultad de ingenieria). Este modelo permite calcular las mejores rutas entre distintos puntos de interes mediante algoritmos de busqueda en grafos.

## Estructura del modelo de datos
### Clase `Nodo`

Representa un punto de interes en el mapa (Sala, laboratorio, oficina, etc.).
```Dart
class Nodo {
  final String id; // Ejemplo: "P1_A101"
  final double x; // Coordenada X en el mapa SVG
  final double y; // Coordenada Y en el mapa SVG

  Nodo({
    required this.id,
    required this.x,
    required this.y,
  });

  // Conversión desde JSON
  factory Nodo.fromJson(Map<String, dynamic> json) {
    return Nodo(
      id: json['id'],
      x: json['x'],
      y: json['y'],
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
      };
}
```

### 2. Clase `Conexion`
Representa una arista entre dos nodos, con la informacion de distancia.
```Dart
class Conexion {
  final String origen;      // ID del nodo origen
  final String destino;     // ID del nodo destino
  final double distancia;   // Distancia euclidiana
  
  const Conexion({
    required this.origen,
    required this.destino,
    required this.distancia,
  });
  
  factory Conexion.fromJson(Map<String, dynamic> json) {
    return Conexion(
      origen: json['origen'] as String,
      destino: json['destino'] as String,
      distancia: (json['distancia'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'origen': origen,
      'destino': destino,
      'distancia': distancia,
    };
  }
}
```

### 3. Clase `Grafo`
Contenedor principal que agrupa los nodos y conexiones de un piso.
```Dart
class Grafo {
  final List<Nodo> nodos;
  final List<Conexion> conexiones;
  
  const Grafo({
    required this.nodos,
    required this.conexiones,
  });
  
  factory Grafo.fromJson(Map<String, dynamic> json) {
    return Grafo(
      nodos: (json['nodos'] as List<dynamic>)
          .map((e) => Nodo.fromJson(e as Map<String, dynamic>))
          .toList(),
      conexiones: (json['conexiones'] as List<dynamic>)
          .map((e) => Conexion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'nodos': nodos.map((n) => n.toJson()).toList(),
      'conexiones': conexiones.map((c) => c.toJson()).toList(),
    };
  }
}
```

---
## Sistema de tipificacion de nodos
La aplicacion implementa un sistema de clasificacion de nodos mediante un `enum` que permite separar por categorias a los diferentes nodos que hay en el mapa.

### Enum `TipoNodo`
```dart
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
```

### Extension de TipoNodo
Cada tipo de nodo tiene asociado un nombre legible, un icono representativo y un color distintivo.

```dart
extension TipoNodoExtension on TipoNodo {
  String get nombre {
    switch (this) {
      case TipoNodo.entrada: return 'Entrada';
      case TipoNodo.pasillo: return 'Pasillo';
      case TipoNodo.interseccion: return 'Intersección';
      case TipoNodo.esquina: return 'Esquina';
      case TipoNodo.puerta: return 'Puerta';
      case TipoNodo.escalera: return 'Escalera';
      case TipoNodo.ascensor: return 'Ascensor';
      case TipoNodo.bano: return 'Baño';
      case TipoNodo.puntoInteres: return 'Punto de Interés';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoNodo.entrada: return Icons.door_front_door;
      case TipoNodo.pasillo: return Icons.straighten;
      case TipoNodo.interseccion: return Icons.merge_type;
      case TipoNodo.esquina: return Icons.turn_right;
      case TipoNodo.puerta: return Icons.meeting_room;
      case TipoNodo.escalera: return Icons.stairs;
      case TipoNodo.ascensor: return Icons.elevator;
      case TipoNodo.bano: return Icons.wc;
      case TipoNodo.puntoInteres: return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case TipoNodo.entrada: return Colors.green;
      case TipoNodo.pasillo: return Colors.blue;
      case TipoNodo.interseccion: return Colors.orange;
      case TipoNodo.esquina: return Colors.purple;
      case TipoNodo.puerta: return Colors.teal;
      case TipoNodo.escalera: return Colors.red;
      case TipoNodo.ascensor: return Colors.indigo;
      case TipoNodo.bano: return Colors.cyan;
      case TipoNodo.puntoInteres: return Colors.amber;
    }
  }
}
```

### Inferencia automatica de tipos
La aplicacion puede inferir el tipo de nodo basandose en el ID del nodo:

```dart
TipoNodo? _obtenerTipoNodoPorId(String id) {
  final idLower = id.toLowerCase();

  if (idLower.contains('entrada')) return TipoNodo.entrada;
  if (idLower.contains('ascensor')) return TipoNodo.ascensor;
  if (idLower.contains('escalera')) return TipoNodo.escalera;
  if (idLower.contains('baño') || idLower.contains('bano')) 
    return TipoNodo.bano;
  if (idLower.contains('pasillo')) return TipoNodo.pasillo;
  if (idLower.contains('interseccion') || idLower.contains('intersección'))
    return TipoNodo.interseccion;
  if (idLower.contains('esquina')) return TipoNodo.esquina;
  if (idLower.contains('puerta')) return TipoNodo.puerta;
  if (idLower.contains('lab') || idLower.contains('sala') || 
      idLower.contains('aula') || idLower.contains('oficina'))
    return TipoNodo.puntoInteres;

  return TipoNodo.puntoInteres; // Tipo por defecto
}
```

---

## Sistema de coordenadas
### Normalizacion SVG
El sistema utilizado para las coordenadas fue, normalizar las coordenadas del archivo SVG a $1200 \times 800$ pixeles, para todos los pisos, independientemente del tamaño real del archivo SVG. Esto permite:
- Consistencia entre los distintos pisos.
- Simplificacion del calculo de las distancias.
- Escalado dinamico a cualquier resolucion de pantalla.

```dart
void _configurarDimensionesSVG() {
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
```

### Transformacion de coordenadas
La aplicacion implementa un sistema de transformacion bidireccional:

#### SVG $to$ Pantalla
```Dart
Offset _calcularPosicionEscalada(double x, double y) {
  final containerSize = /* tamaño del contenedor */;
  
  // Calcular escala manteniendo aspect ratio (BoxFit.contain)
  final scaleX = containerSize.width / _svgWidthOriginal;
  final scaleY = containerSize.height / _svgHeightOriginal;
  final scale = scaleX < scaleY ? scaleX : scaleY;
  
  // Dimensiones escaladas
  final scaledWidth = _svgWidthOriginal * scale;
  final scaledHeight = _svgHeightOriginal * scale;
  
  // Offsets para centrado
  final offsetX = (containerSize.width - scaledWidth) / 2;
  final offsetY = (containerSize.height - scaledHeight) / 2;
  
  // Aplicar transformación
  final scaledX = (x * scale) + offsetX;
  final scaledY = (y * scale) + offsetY;
  
  return Offset(scaledX, scaledY);
}
```

#### Pantalla $to$ SVG
```Dart
Offset _calcularCoordenadasSVG(Offset screenPosition) {
  // ... cálculo de scale y offsets ...
  
  // Transformación inversa
  final svgX = (screenPosition.dx - offsetX) / scale;
  final svgY = (screenPosition.dy - offsetY) / scale;
  
  return Offset(svgX, svgY);
}
```

## Estructura de archivos JSON
### Formato del grafo
Cada piso de la facultad tiene su archivo JSON correspondiente con la siguiente estructura:
```json
{
  "nodos": [
    {
      "id": "P1_Entrada",
      "x": 100,
      "y": 400,
      "tipo": "entrada",
      "nombre": "Entrada Principal"
    },
    {
      "id": "P1_A101",
      "x": 300,
      "y": 200,
      "tipo": "aula",
      "nombre": "Aula 101"
    }
  ],
  "conexiones": [
    {
      "origen": "P1_Entrada",
      "destino": "P1_A101",
      "distancia": 223.6
    }
  ]
}
```

### Nomenclatura de ID
Los identificadores de nodos siguen el patron `P{piso}_{tipo}{numero}:`
- `P1_Entrada`: Entrada de la facultad.
- `P2_Sala_23`: Sala 23 del segundo piso.
- `P3_Departamento_matematica_fisica`: Departamento de matematica y fisica del tercer piso.
- `P4_Sala_42`: Sala 42 del cuarto piso.

#### Ubicacion de los archivos:
```
lib/data/
├── grafo_piso1.json
├── grafo_piso2.json
├── grafo_piso3.json
└── grafo_piso4.json
```

## Carga dinamica del grafo
### Utilidad de carga (`grafo_loader.dart`)
```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grafo.dart';

Future<Grafo> cargarGrafo(String rutaArchivo) async {
  final data = await rootBundle.loadString(rutaArchivo);
  final jsonData = json.decode(data);
  return Grafo.fromJson(jsonData);
}
```

### Implementacion en la aplicación
```dart
String get rutaGrafoJson {
  switch (widget.numeroPiso) {
    case 1: return 'lib/data/grafo_piso1.json';
    case 2: return 'lib/data/grafo_piso2.json';
    case 3: return 'lib/data/grafo_piso3.json';
    case 4: return 'lib/data/grafo_piso4.json';
    default: return 'lib/data/grafo_piso1.json';
  }
}

Future<void> _cargarNodos() async {
  try {
    final raw = await rootBundle.loadString(rutaGrafoJson);
    final data = json.decode(raw) as Map<String, dynamic>;
    _nodos = List<Map<String, dynamic>>.from(
      data['nodos'] as List<dynamic>
    );
  } catch (e) {
    print('Error cargando nodos: $e');
  }
}
```

### Inicializacion del mapa

```dart
Future<void> _inicializarMapa() async {
  try {
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
      print('ERROR inicialización: $e');
    }
  }
}
```

---

## Visualizacion de nodos
### Renderizado de marcadores
Los nodos se visualizan en el mapa como marcadores circulares sobre el mapa SVG:
```dart
Widget _buildNodoMarker(Map<String, dynamic> nodo) {
  final x = (nodo['x'] as num).toDouble();
  final y = (nodo['y'] as num).toDouble();
  final id = nodo['id'] as String;
  
  final posicionEscalada = _calcularPosicionEscalada(x, y);
  
  return Positioned(
    left: posicionEscalada.dx - 6,
    top: posicionEscalada.dy - 6,
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
              color: Colors.black.withAlpha(77),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(_obtenerIconoNodo(id), color: Colors.white, size: 7),
      ),
    ),
  );
}
```
### Sistema de colores dinamico

```dart
Color _obtenerColorNodo(Map<String, dynamic> nodo) {
  // Si el nodo tiene tipo guardado
  if (nodo['tipo'] != null) {
    try {
      final tipo = TipoNodo.values.firstWhere(
        (t) => t.name == nodo['tipo'],
      );
      return tipo.color;
    } catch (e) {
      // Continuar con inferencia
    }
  }

  // Inferir por ID
  final tipoInferido = _obtenerTipoNodoPorId(nodo['id'] as String);
  if (tipoInferido != null) {
    return tipoInferido.color;
  }

  return Colors.blue.shade500; // Color por defecto
}
```

### Iconografia por tipo
```dart
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
```

## Herramientas de desarrollo
### Modo Debug
La aplicacion incluye un modo de desarollo para facilitar la creacion del grafo:
```dart
const bool kDebugMode = true;  // Cambiar a false en producción

bool _modoDebugActivo = kDebugMode;
final List<Map<String, dynamic>> _coordenadasDebug = [];
final List<Map<String, dynamic>> _conexionesDebug = [];
```

#### Activacion/Desactivacion
#### Activación/Desactivación

```dart
void _toggleModoDebug() {
  setState(() {
    _modoDebugActivo = !_modoDebugActivo;
    if (!_modoDebugActivo) {
      _coordenadasDebug.clear();
      _conexionesDebug.clear();
    }
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() {});
    }
  });
}
```

### Captura de coordenadas
El modo debug permite capturar coordenadas tocando el mapa:

```dart
void _handleDebugTap(TapDownDetails details) {
  if (!_modoDebugActivo) return;

  final RenderBox? containerBox =
      _containerKey.currentContext?.findRenderObject() as RenderBox?;
  
  if (containerBox == null) return;

  final localPosition = containerBox.globalToLocal(details.globalPosition);
  final svgCoords = _calcularCoordenadasSVG(localPosition);

  setState(() {
    _coordenadasDebug.add({
      'x': svgCoords.dx.toInt(),
      'y': svgCoords.dy.toInt(),
      'timestamp': DateTime.now(),
    });
  });

  _mostrarDialogoCoordenadas(svgCoords.dx, svgCoords.dy);
}
```

### Dialogo de creacion de nodos
```dart
void _mostrarDialogoCoordenadas(double x, double y) {
  final TextEditingController idController = TextEditingController();
  TipoNodo? tipoSeleccionado;

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de tipo
            DropdownButtonFormField<TipoNodo>(
              decoration: InputDecoration(
                labelText: 'Tipo de nodo',
                border: const OutlineInputBorder(),
              ),
              value: tipoSeleccionado,
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
            // Campo de ID
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'ID del nodo',
                prefixIcon: const Icon(Icons.label),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '{"id": "${idController.text}", "x": ${x.toInt()}, "y": ${y.toInt()}, "tipo": "${tipoSeleccionado?.name}"}',
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Copiar JSON'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _nodos.add({
                  'id': idController.text,
                  'x': x.toInt(),
                  'y': y.toInt(),
                  'tipo': tipoSeleccionado?.name,
                });
              });
              Navigator.of(context).pop();
            },
            child: const Text('Agregar Nodo'),
          ),
        ],
      ),
    ),
  );
}
```

### Generacion automatica de IDs

```dart
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
```

### Creacion de conexiones
La herramienta permite crear conexiones entre los nodos existentes dentro de los archivos json de los mapas:

```dart
void _crearConexion() {
  if (_nodos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay nodos disponibles para crear conexiones'),
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
        title: const Text('Crear Conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de nodo origen
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Nodo Origen',
                prefixIcon: Icon(Icons.start),
              ),
              items: _nodos.map((nodo) {
                return DropdownMenuItem(
                  value: nodo['id'] as String,
                  child: Text(nodo['id'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setDialogState(() {
                  origenSeleccionado = value;
                  if (destinoSeleccionado != null && value != null) {
                    distanciaCalculada = _calcularDistanciaEntreNodos(
                      value, destinoSeleccionado!
                    );
                  }
                });
              },
            ),
            // Selector de nodo destino
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Nodo Destino',
                prefixIcon: Icon(Icons.flag),
              ),
              items: _nodos.map((nodo) {
                return DropdownMenuItem(
                  value: nodo['id'] as String,
                  child: Text(nodo['id'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setDialogState(() {
                  destinoSeleccionado = value;
                  if (origenSeleccionado != null && value != null) {
                    distanciaCalculada = _calcularDistanciaEntreNodos(
                      origenSeleccionado!, value
                    );
                  }
                });
              },
            ),
            // Mostrar distancia calculada
            if (distanciaCalculada != null)
              Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Distancia: ${distanciaCalculada!.toStringAsFixed(2)} px',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: (origenSeleccionado != null && 
                        destinoSeleccionado != null)
              ? () {
                  setState(() {
                    _conexionesDebug.add({
                      'origen': origenSeleccionado!,
                      'destino': destinoSeleccionado!,
                      'distancia': distanciaCalculada!.round(),
                    });
                  });
                  Navigator.of(context).pop();
                }
              : null,
            child: const Text('Crear Conexión'),
          ),
        ],
      ),
    ),
  );
}
```

### Calculo de distancias

```dart
double _calcularDistanciaEntreNodos(String idOrigen, String idDestino) {
  final nodoOrigen = _nodos.firstWhere((nodo) => nodo['id'] == idOrigen);
  final nodoDestino = _nodos.firstWhere((nodo) => nodo['id'] == idDestino);

  final x1 = (nodoOrigen['x'] as num).toDouble();
  final y1 = (nodoOrigen['y'] as num).toDouble();
  final x2 = (nodoDestino['x'] as num).toDouble();
  final y2 = (nodoDestino['y'] as num).toDouble();

  // Distancia euclidiana
  return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
}
```

### Visualizacion de conexiones
Las conexiones se visualizan como lineas con flechas sobre el mapa:

```dart
Widget _buildConexionLinea(Map<String, dynamic> conexion) {
  final origenId = conexion['origen'] as String;
  final destinoId = conexion['destino'] as String;

  final nodoOrigen = _nodos.firstWhere((nodo) => nodo['id'] == origenId);
  final nodoDestino = _nodos.firstWhere((nodo) => nodo['id'] == destinoId);

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
```

### Custom Painter para conexiones

```dart
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
    // Dibujar línea
    final paint = Paint()
      ..color = Colors.green.shade600.withAlpha((0.7 * 255).round())
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

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

    // Dibujar distancia
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
```

### Exportacion de datos

#### Exportar coordenadas
```dart
void _exportarCoordenadasDebug() {
  if (_coordenadasDebug.isEmpty) return;

  final nodosJson = _coordenadasDebug.asMap().entries.map((entry) => {
    'id': 'Nodo_${entry.key + 1}',
    'x': entry.value['x'],
    'y': entry.value['y'],
  }).toList();

  final jsonData = {'nodos': nodosJson, 'conexiones': []};
  final json = JsonEncoder.withIndent('  ').convert(jsonData);

  Clipboard.setData(ClipboardData(text: json));
}
```

#### Exportar conexiones
```dart
void _exportarConexionesDebug() {
  if (_conexionesDebug.isEmpty) return;

  final conexionesJson = _conexionesDebug.map((conexion) => {
    'origen': conexion['origen'],
    'destino': conexion['destino'],
    'distancia': conexion['distancia'],
  }).toList();

  final json = JsonEncoder.withIndent('  ').convert({
    'conexiones': conexionesJson,
  });

  Clipboard.setData(ClipboardData(text: json));
}
```

### Estadisticas de nodos
```dart
void _mostrarEstadisticasNodos() {
  final estadisticas = <TipoNodo, int>{};
  for (final tipo in TipoNodo.values) {
    estadisticas[tipo] = 0;
  }

  int nodosConTipo = 0;
  int nodosSinTipo = 0;

  for (final nodo in _nodos) {
    if (nodo['tipo'] != null) {
      try {
        final tipo = TipoNodo.values.firstWhere(
          (t) => t.name == nodo['tipo'],
        );
        estadisticas[tipo] = (estadisticas[tipo] ?? 0) + 1;
        nodosConTipo++;
      } catch (e) {
        final tipoInferido = _obtenerTipoNodoPorId(nodo['id'] as String);
        if (tipoInferido != null) {
          estadisticas[tipoInferido] = (estadisticas[tipoInferido] ?? 0) + 1;
          nodosConTipo++;
        } else {
          nodosSinTipo++;
        }
      }
    }
  }

  // Mostrar diálogo con estadísticas...
}
```

### Migracion de tipos de nodos
La herramienta permite migrar nodos existentes agregando tipos automaticamente:

```dart
Future<void> _migrarNodosConTipo() async {
  try {
    final raw = await rootBundle.loadString(rutaGrafoJson);
    final data = json.decode(raw) as Map<String, dynamic>;
    final nodos = List<Map<String, dynamic>>.from(
      data['nodos'] as List<dynamic>,
    );
    final conexiones = data['conexiones'] as List<dynamic>;

    int nodosActualizados = 0;
    int nodosSinCambios = 0;

    final nodosConTipo = nodos.map((nodo) {
      if (nodo['id'] == null || (nodo['id'] as String).isEmpty) {
        return nodo;
      }

      if (nodo['tipo'] != null) {
        nodosSinCambios++;
        return nodo;
      }

      final tipoInferido = _obtenerTipoNodoPorId(nodo['id'] as String);
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

    final jsonActualizado = JsonEncoder.withIndent('  ').convert({
      'nodos': nodosConTipo,
      'conexiones': conexiones,
    });

    await Clipboard.setData(ClipboardData(text: jsonActualizado));

    // Mostrar resultados...
  } catch (e) {
    print('Error en migración: $e');
  }
}
```

### Recarga de nodos
```dart
Future<void> _recargarNodosDesdeArchivo() async {
  try {
    final raw = await rootBundle.loadString(rutaGrafoJson);
    final data = json.decode(raw) as Map<String, dynamic>;
    final nodosRaw = List<Map<String, dynamic>>.from(
      data['nodos'] as List<dynamic>,
    );

    final nodosNuevos = nodosRaw.where((nodo) {
      return nodo['id'] != null &&
          nodo['x'] != null &&
          nodo['y'] != null &&
          (nodo['id'] as String).isNotEmpty;
    }).toList();

    setState(() {
      _nodos = nodosNuevos;
      _coordenadasDebug.clear();
      _conexionesDebug.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ ${_nodos.length} nodos recargados desde archivo'),
      ),
    );
  } catch (e) {
    print('Error al recargar: $e');
  }
}
```

---

## Marcadores visuales
### Marcador de nodo debug
Los puntos capturados en el modo debug se visualizan de color anaranjado:

```dart
Widget _buildDebugMarker(Map<String, dynamic> coord) {
  final x = (coord['x'] as num).toDouble();
  final y = (coord['y'] as num).toDouble();
  final timestamp = coord['timestamp'] as DateTime;

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
              children: [
                Text('X (SVG): ${x.toInt()}'),
                Text('Y (SVG): ${y.toInt()}'),
                Text('Hora: ${timestamp.hour}:${timestamp.minute}:${timestamp.second}'),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  );
}
```

---
