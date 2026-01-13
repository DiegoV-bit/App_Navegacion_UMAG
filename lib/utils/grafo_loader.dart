import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grafo.dart';

/// Carga un grafo desde un archivo JSON ubicado en los assets de la aplicación.
///
/// Esta función:
/// 1. Lee el archivo JSON desde los assets usando [rootBundle]
/// 2. Decodifica el contenido JSON a un Map de Dart
/// 3. Convierte el Map en una instancia de [Grafo] usando el factory constructor
///
/// Parámetros:
/// - [rutaArchivo]: Ruta relativa al archivo JSON dentro de los assets
///   (ejemplo: "lib/data/grafo_piso1.json")
///
/// Retorna:
/// - Un [Future] que se resuelve con la instancia del [Grafo] cargado
///
/// Ejemplo de uso:
/// ```dart
/// final grafo = await cargarGrafo('lib/data/grafo_piso1.json');
/// print('Grafo cargado con ${grafo.nodos.length} nodos');
/// ```
///
/// Nota: Los archivos JSON deben estar declarados en el pubspec.yaml
/// en la sección de assets para poder ser cargados.
Future<Grafo> cargarGrafo(String rutaArchivo) async {
  final data = await rootBundle.loadString(rutaArchivo);
  final jsonData = json.decode(data);
  return Grafo.fromJson(jsonData);
}
