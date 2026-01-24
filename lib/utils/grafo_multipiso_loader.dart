import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grafo.dart';
import '../models/grafo_multipiso.dart';

/// Carga el grafo multi-piso completo del edificio
Future<GrafoMultiPiso> cargarGrafoMultiPiso() async {
  print('🔄 Iniciando carga de grafo multi-piso...');

  final grafosPorPiso = <int, Grafo>{};

  // Cargar grafos individuales de cada piso
  for (int i = 1; i <= 4; i++) {
    try {
      final rutaGrafo = 'lib/data/grafo_piso$i.json';
      print('  📂 Cargando: $rutaGrafo');
      final jsonString = await rootBundle.loadString(rutaGrafo);
      final jsonData = json.decode(jsonString);
      grafosPorPiso[i] = Grafo.fromJson(jsonData);
      print('  ✅ Piso $i cargado correctamente');
    } catch (e) {
      print('  ❌ Error al cargar piso $i: $e');
      rethrow;
    }
  }

  // Cargar conexiones verticales
  try {
    print('  📂 Cargando conexiones verticales...');
    final conexionesJson = await rootBundle.loadString(
      'lib/data/conexiones_verticales.json',
    );
    final conexionesData = json.decode(conexionesJson);
    final conexiones = (conexionesData['conexionesVerticales'] as List)
        .map((c) => ConexionVertical.fromJson(c))
        .toList();

    print('  ✅ ${conexiones.length} conexiones verticales cargadas');

    return GrafoMultiPiso(
      grafosPorPiso: grafosPorPiso,
      conexionesVerticales: conexiones,
    );
  } catch (e) {
    print('  ❌ Error al cargar conexiones verticales: $e');
    rethrow;
  }
}
