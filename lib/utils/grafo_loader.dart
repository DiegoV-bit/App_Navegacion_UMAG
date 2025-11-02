import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grafo.dart';

Future<Grafo> cargarGrafo(String rutaArchivo) async {
  final data = await rootBundle.loadString(rutaArchivo);
  final jsonData = json.decode(data);
  return Grafo.fromJson(jsonData);
}
