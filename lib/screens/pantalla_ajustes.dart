import 'package:flutter/material.dart';

class PantallaAjustes extends StatefulWidget {
  final Function(ThemeMode) onCambiarTema;
  final ThemeMode themeModeActual;

  const PantallaAjustes({
    super.key,
    required this.onCambiarTema,
    required this.themeModeActual,
  });

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  late ThemeMode _modoSeleccionado;

  @override
  void initState() {
    super.initState();
    _modoSeleccionado = widget.themeModeActual;
  }

  void _cambiarModo(ThemeMode modo) {
    setState(() {
      _modoSeleccionado = modo;
    });
    widget.onCambiarTema(modo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Apariencia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('Automático'),
            subtitle: const Text('Usar tema del sistema'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _modoSeleccionado,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  _cambiarModo(value);
                }
              },
            ),
            onTap: () => _cambiarModo(ThemeMode.system),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Modo Claro'),
            subtitle: const Text('Interfaz con colores claros'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _modoSeleccionado,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  _cambiarModo(value);
                }
              },
            ),
            onTap: () => _cambiarModo(ThemeMode.light),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Interfaz con colores oscuros'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _modoSeleccionado,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  _cambiarModo(value);
                }
              },
            ),
            onTap: () => _cambiarModo(ThemeMode.dark),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Acerca de',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versión'),
            subtitle: Text('1.01'),
          ),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Universidad de Magallanes'),
            subtitle: Text('Facultad de Ingeniería'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Desarrollador',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Desarrollado por'),
            subtitle: const Text('DiegoV-bit'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Información del Desarrollador'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Desarrollado por: DiegoV-bit'),
                      SizedBox(height: 8),
                      Text('GitHub: github.com/DiegoV-bit'),
                      SizedBox(height: 8),
                      Text('Proyecto: App de Navegación UMAG'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('GitHub'),
            subtitle: Text('github.com/DiegoV-bit'),
          ),
          const ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Año'),
            subtitle: Text('2026'),
          ),
        ],
      ),
    );
  }
}
