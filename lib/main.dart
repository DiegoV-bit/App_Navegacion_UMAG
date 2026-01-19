import 'package:flutter/material.dart';

// Imports de pantallas
import 'screens/pantalla_inicio.dart';

void main() {
  runApp(const NavegacionUMAGApp());
}

class NavegacionUMAGApp extends StatefulWidget {
  const NavegacionUMAGApp({super.key});

  @override
  State<NavegacionUMAGApp> createState() => _NavegacionUMAGAppState();
}

class _NavegacionUMAGAppState extends State<NavegacionUMAGApp> {
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
      debugShowCheckedModeBanner: false,
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
