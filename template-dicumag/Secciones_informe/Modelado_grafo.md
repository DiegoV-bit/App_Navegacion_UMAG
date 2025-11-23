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

## Sistema de coordenadas
### Normalizacion SVG
El sistema utilizado para las coordenadas fue, normalizar las coordenadas del archivo SVG a $1200 \times 800$ pixeles, para todos los pisos, independientemente del tamaño real del archivo SVG. Esto permite:
- Consistencia entre los distintos pisos.
- Simplificacion del calculo de las distancias.
- Escalado dinamico a cualquier resolucion de pantalla.

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

#### Implementacion en la aplicación
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

#### Iconografia por tipo
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
const bool kDebugMode = false;  // Activar para desarrollo
```
El modo debug permite poner nodos de color naranja (estos nodos son los nodos debug), cuando poner un nodo en el mapa este da sus coordenadas (x,y) y la posibilidad de poner un nombre al nodo, esta implementacion hace te genere el codigo para el archivo json que agrega los nodos al mapa.