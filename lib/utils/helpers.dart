import 'package:flutter/material.dart';
import 'tipos_nodo.dart';

class MapaHelpers {
  /// Obtiene la ruta del archivo SVG para un piso específico
  static String getRutaArchivoPorPiso(int piso) {
    switch (piso) {
      case 1:
        return 'Mapas/Primer piso fac_ing simple.svg';
      case 2:
        return 'Mapas/Segundo piso fac_ing simple.svg';
      case 3:
        return 'Mapas/Tercer piso fac_ing simple.svg';
      case 4:
        return 'Mapas/Cuarto piso fac_ing simple.svg';
      default:
        return 'Mapas/Primer piso fac_ing simple.svg';
    }
  }

  /// Obtiene la ruta del archivo JSON del grafo para un piso específico
  static String getRutaGrafoPorPiso(int piso) {
    switch (piso) {
      case 1:
        return 'lib/data/grafo_piso1.json';
      case 2:
        return 'lib/data/grafo_piso2.json';
      case 3:
        return 'lib/data/grafo_piso3.json';
      case 4:
        return 'lib/data/grafo_piso4.json';
      default:
        return 'lib/data/grafo_piso1.json';
    }
  }

  /// Obtiene el nombre legible del archivo SVG para un piso
  static String getNombreArchivoPorPiso(int piso) {
    switch (piso) {
      case 1:
        return 'Primer piso fac_ing simple.svg';
      case 2:
        return 'Segundo piso fac_ing simple.svg';
      case 3:
        return 'Tercer piso fac_ing simple.svg';
      case 4:
        return 'Cuarto piso fac_ing simple.svg';
      default:
        return 'Primer piso fac_ing simple.svg';
    }
  }

  /// Intenta inferir el tipo de nodo basándose en su ID
  static TipoNodo? obtenerTipoNodoPorId(String id) {
    final idLower = id.toLowerCase();

    if (idLower.contains('entrada')) return TipoNodo.entrada;
    if (idLower.contains('ascensor')) return TipoNodo.ascensor;
    if (idLower.contains('escalera')) return TipoNodo.escalera;
    if (idLower.contains('baño') || idLower.contains('bano')) {
      return TipoNodo.bano;
    }
    if (idLower.contains('pasillo')) return TipoNodo.pasillo;
    if (idLower.contains('interseccion') || idLower.contains('intersección')) {
      return TipoNodo.interseccion;
    }
    if (idLower.contains('esquina')) return TipoNodo.esquina;
    if (idLower.contains('puerta')) return TipoNodo.puerta;
    if (idLower.contains('lab')) return TipoNodo.laboratorio;
    if (idLower.contains('sala') || idLower.contains('aula')) {
      return TipoNodo.salaClases;
    }
    if (idLower.contains('oficina') ||
        idLower.contains('secretaria') ||
        idLower.contains('administracion') ||
        idLower.contains('patio') ||
        idLower.contains('cafeteria') ||
        idLower.contains('biblioteca')) {
      return TipoNodo.puntoInteres;
    }

    return TipoNodo.puntoInteres;
  }

  /// Genera un ID único para un nuevo nodo
  static String generarIdNodo(TipoNodo tipo, int piso) {
    final prefijo = 'P$piso';
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
      case TipoNodo.laboratorio:
        return '${prefijo}_Lab_$timestamp';
      case TipoNodo.salaClases:
        return '${prefijo}_Sala_$timestamp';
      case TipoNodo.puntoInteres:
        return '${prefijo}_PuntoInteres_$timestamp';
    }
  }

  /// Extrae el número de piso del ID de un nodo
  static int extraerPisoDeNodoId(String nodoId) {
    if (nodoId.startsWith('P') && nodoId.length > 1) {
      final pisoChar = nodoId[1];
      return int.tryParse(pisoChar) ?? 1;
    }
    return 1;
  }

  /// Obtiene el tipo de lugar basado en el ID (versión legacy)
  static String obtenerTipoLugar(String id) {
    if (id.contains('Entrada')) return 'Entrada principal';
    if (id.contains('Pasillo')) return 'Pasillo';
    if (id.contains('Sala') || id.contains('Aula')) return 'Sala de Clases';
    if (id.contains('Lab')) return 'Laboratorio';
    if (id.contains('Oficina')) return 'Oficina';
    if (id.contains('Baño')) return 'Baño';
    if (id.contains('Escalera')) return 'Escalera';
    if (id.contains('Ascensor')) return 'Ascensor';
    return 'Punto de interés';
  }

  /// Obtiene el icono para un nodo basado en su ID (versión legacy)
  static IconData obtenerIconoNodo(String id) {
    if (id.contains('Entrada')) return Icons.door_front_door;
    if (id.contains('Pasillo')) return Icons.swap_horiz;
    if (id.contains('Sala') || id.contains('Aula')) return Icons.class_;
    if (id.contains('Lab')) return Icons.science;
    if (id.contains('Oficina')) return Icons.business;
    if (id.contains('Baño')) return Icons.wc;
    if (id.contains('Escalera')) return Icons.stairs;
    if (id.contains('Ascensor')) return Icons.elevator;
    return Icons.place;
  }
}
