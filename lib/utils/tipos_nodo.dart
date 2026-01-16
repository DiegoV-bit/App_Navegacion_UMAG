import 'package:flutter/material.dart';

enum TipoNodo {
  entrada,
  pasillo,
  interseccion,
  esquina,
  puerta,
  escalera,
  ascensor,
  bano,
  laboratorio,
  salaClases,
  puntoInteres,
}

extension TipoNodoExtension on TipoNodo {
  String get nombre {
    switch (this) {
      case TipoNodo.entrada:
        return 'Entrada';
      case TipoNodo.pasillo:
        return 'Pasillo';
      case TipoNodo.interseccion:
        return 'Intersección';
      case TipoNodo.esquina:
        return 'Esquina';
      case TipoNodo.puerta:
        return 'Puerta';
      case TipoNodo.escalera:
        return 'Escalera';
      case TipoNodo.ascensor:
        return 'Ascensor';
      case TipoNodo.bano:
        return 'Baño';
      case TipoNodo.laboratorio:
        return 'Laboratorio';
      case TipoNodo.salaClases:
        return 'Sala de Clases';
      case TipoNodo.puntoInteres:
        return 'Punto de Interés';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoNodo.entrada:
        return Icons.door_front_door;
      case TipoNodo.pasillo:
        return Icons.straighten;
      case TipoNodo.interseccion:
        return Icons.merge_type;
      case TipoNodo.esquina:
        return Icons.turn_right;
      case TipoNodo.puerta:
        return Icons.meeting_room;
      case TipoNodo.escalera:
        return Icons.stairs;
      case TipoNodo.ascensor:
        return Icons.elevator;
      case TipoNodo.bano:
        return Icons.wc;
      case TipoNodo.laboratorio:
        return Icons.science;
      case TipoNodo.salaClases:
        return Icons.class_;
      case TipoNodo.puntoInteres:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case TipoNodo.entrada:
        return Colors.green;
      case TipoNodo.pasillo:
        return Colors.blue;
      case TipoNodo.interseccion:
        return Colors.orange;
      case TipoNodo.esquina:
        return Colors.purple;
      case TipoNodo.puerta:
        return Colors.teal;
      case TipoNodo.escalera:
        return Colors.red;
      case TipoNodo.ascensor:
        return Colors.indigo;
      case TipoNodo.bano:
        return Colors.cyan;
      case TipoNodo.laboratorio:
        return Colors.lightGreen;
      case TipoNodo.salaClases:
        return Colors.lightBlue;
      case TipoNodo.puntoInteres:
        return Colors.amber;
    }
  }

  String get descripcion {
    switch (this) {
      case TipoNodo.entrada:
        return 'Punto de acceso principal al edificio';
      case TipoNodo.pasillo:
        return 'Corredor de tránsito';
      case TipoNodo.interseccion:
        return 'Cruce de pasillos';
      case TipoNodo.esquina:
        return 'Cambio de dirección en pasillo';
      case TipoNodo.puerta:
        return 'Acceso a sala u oficina';
      case TipoNodo.escalera:
        return 'Conexión vertical entre pisos';
      case TipoNodo.ascensor:
        return 'Elevador entre pisos';
      case TipoNodo.bano:
        return 'Servicios higiénicos';
      case TipoNodo.laboratorio:
        return 'Espacio de experimentación y práctica';
      case TipoNodo.salaClases:
        return 'Sala de enseñanza';
      case TipoNodo.puntoInteres:
        return 'Lugar relevante del edificio';
    }
  }
}
