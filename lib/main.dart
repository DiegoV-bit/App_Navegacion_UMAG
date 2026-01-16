import 'package:flutter/material.dart';

// Imports de pantallas
import 'screens/pantalla_inicio.dart';

void main() {
  runApp(const NavigacionUMAGApp());
}

class NavigacionUMAGApp extends StatefulWidget {
  const NavigacionUMAGApp({super.key});

  @override
  State<NavigacionUMAGApp> createState() => _NavigacionUMAGAppState();
}

class _NavigacionUMAGAppState extends State<NavigacionUMAGApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _cambiarTema(ThemeMode modo) {
    setState(() {
      _themeMode = modo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegación UMAG',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: PantallaInicio(
        onCambiarTema: _cambiarTema,
        themeModeActual: _themeMode,
      ),
    );
  }
}
