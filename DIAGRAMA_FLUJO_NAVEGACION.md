# 🔄 Diagrama de Flujo - Nueva Navegación con QR

## Flujo Anterior (Problema) ❌

```
┌─────────────────┐
│  Usuario en     │
│  Mapa (Piso X)  │
└────────┬────────┘
         │
         │ Presiona botón QR
         ▼
┌─────────────────┐
│  Escanea QR     │
│  (P1_Entrada_1) │
└────────┬────────┘
         │
         │ QR detectado
         ▼
┌─────────────────┐
│  Botón          │
│  "Navegar"      │  ◄── NO HACE NADA ❌
│  (vacío)        │
└─────────────────┘
```

## Flujo Nuevo (Solución) ✅

```
┌──────────────────┐
│   Usuario en     │
│   Mapa (Piso 1)  │
└────────┬─────────┘
         │
         │ 1. Presiona botón "Escanear QR"
         ▼
┌──────────────────┐
│  Pantalla QR     │
│  Scanner         │
│  [Camera View]   │
└────────┬─────────┘
         │
         │ 2. Apunta al QR
         ▼
┌──────────────────┐
│  QR Detectado    │
│  {"type":"nodo", │
│   "id":"P1_..."] │
└────────┬─────────┘
         │
         │ 3. Valida formato (codigo_qr.dart)
         ▼
┌──────────────────┐
│  navegacion_qr   │
│  .procesarQR()   │
└────────┬─────────┘
         │
         │ 4. Es tipo "nodo"
         ▼
┌──────────────────────────────────────┐
│  PantallaSeleccionDestino            │
│  ┌────────────────────────────────┐  │
│  │ 📍 Ubicación Actual            │  │
│  │    Entrada 1                   │  │
│  │    Piso 1                      │  │
│  └────────────────────────────────┘  │
│                                      │
│  🎯 ¿A dónde deseas ir?              │
│  ┌────────────────────────────────┐  │
│  │ [Selecciona tu destino ▼]     │  │ ◄── 5. Usuario abre dropdown
│  │                                │  │
│  │ • 🚪 Entrada 2                 │  │
│  │ • 🚶 Pasillo Norte             │  │
│  │ • 🚪 Aula A101                 │  │
│  │ • 🔬 Laboratorio 1             │  │
│  │ • 💼 Oficina Decanato          │  │
│  │ • 🚽 Baños Piso 1              │  │
│  │ • 🪜 Escalera Norte            │  │
│  │ ...                            │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
         │
         │ 6. Selecciona "Aula A101"
         ▼
┌──────────────────────────────────────┐
│  [Calcular Ruta] 🧮                  │ ◄── 7. Presiona botón
└────────┬─────────────────────────────┘
         │
         │ 8. Ejecuta A* (a_estrella.dart)
         ▼
┌──────────────────────────────────────┐
│  ⏳ Calculando ruta óptima...        │
└────────┬─────────────────────────────┘
         │
         │ 9. Ruta encontrada
         ▼
┌──────────────────────────────────────┐
│  ✅ Ruta Encontrada                  │
│  ┌────────────────────────────────┐  │
│  │ 📏 Distancia: 150.5 unidades   │  │
│  │ 👣 Pasos: 7                    │  │
│  │                                │  │
│  │ Recorrido:                     │  │
│  │ 🟢 1. Entrada 1                │  │
│  │ 🔵 2. Pasillo Central          │  │
│  │ 🔵 3. Intersección A           │  │
│  │ 🔵 4. Pasillo Aulas            │  │
│  │ 🔵 5. Esquina Norte            │  │
│  │ 🔵 6. Puerta A101              │  │
│  │ 🔴 7. Aula A101                │  │
│  └────────────────────────────────┘  │
│                                      │
│  [Iniciar Navegación] 🧭             │ ◄── 10. Presiona botón
└────────┬─────────────────────────────┘
         │
         │ 11. Retorna al mapa con ruta
         ▼
┌──────────────────────────────────────┐
│  Mapa (Piso 1)                       │
│  ┌────────────────────────────────┐  │
│  │         🏛️                     │  │
│  │    🟢──🔵──🔵                  │  │
│  │           │                    │  │
│  │          🔵──🔵──🔵──🔴       │  │
│  │                                │  │
│  │  [Ruta visualizada con         │  │
│  │   RutaPainter]                 │  │
│  └────────────────────────────────┘  │
│                                      │
│  ✅ Ruta calculada: 7 pasos          │ ◄── Notificación
└──────────────────────────────────────┘
```

## Componentes Involucrados

### 1. main.dart
- **Método**: `_abrirScannerQR()`
- **Rol**: Inicia el proceso y recibe la ruta calculada
- **Actualiza**: `_rutaActiva` para visualización

### 2. pantalla_lectora_qr.dart
- **Clase**: `QRScannerScreen`
- **Rol**: Captura el código QR con la cámara
- **Delega a**: navegacion_qr.dart

### 3. codigo_qr.dart
- **Métodos**: `parseQRCode()`, `esQRValido()`
- **Rol**: Valida y parsea el formato JSON/legacy
- **Soporta**: JSON y formatos legacy

### 4. navegacion_qr.dart
- **Clase**: `QRNavigation`
- **Método clave**: `_navegarANodo()`
- **Rol**: Redirige a PantallaSeleccionDestino
- **Retorna**: Ruta calculada al mapa

### 5. pantalla_seleccion_destino.dart ⭐ NUEVO
- **Clase**: `PantallaSeleccionDestino`
- **Funciones**:
  - Muestra origen escaneado
  - Dropdown con destinos disponibles
  - Botón calcular ruta
  - Visualización paso a paso
  - Botón iniciar navegación
- **Usa**: A* para cálculo de ruta

### 6. a_estrella.dart
- **Clase**: `AStar`
- **Método**: `calcularRuta()`
- **Rol**: Algoritmo de búsqueda de caminos
- **Retorna**: Lista de nodos (ruta óptima)

### 7. grafo.dart, nodo.dart
- **Modelos**: `Grafo`, `Nodo`, `Conexion`
- **Rol**: Estructuras de datos del mapa
- **Carga desde**: JSON (grafo_piso[1-4].json)

## Datos Transferidos

```
┌─────────────┐        ┌──────────────┐        ┌─────────────┐
│   Scanner   │───────>│  Navegación  │───────>│  Selección  │
│     QR      │  nodo  │      QR      │  nodo  │   Destino   │
└─────────────┘  data  └──────────────┘   id   └─────────────┘
                                                       │
                                                       │ ruta
                                                       │ calculada
                                                       ▼
┌─────────────┐        ┌──────────────┐        ┌─────────────┐
│    Mapa     │<───────│  Navegación  │<───────│  Selección  │
│  (visualiza)│  ruta  │      QR      │  Map   │   Destino   │
└─────────────┘  activa└──────────────┘  result└─────────────┘

Datos retornados:
{
  'ruta': ['P1_Entrada_1', 'P1_Pasillo_Central', ... , 'P1_Aula_A101'],
  'origen': 'P1_Entrada_1',
  'destino': 'P1_Aula_A101',
  'distancia': 150.5
}
```

## Estados de la UI

### Estado 1: Inicial
- Dropdown: Habilitado, vacío
- Botón "Calcular Ruta": Oculto
- Vista recorrido: Oculta
- Botón "Iniciar Navegación": Oculto

### Estado 2: Destino Seleccionado
- Dropdown: Habilitado, con valor
- Botón "Calcular Ruta": Visible ✅
- Vista recorrido: Oculta
- Botón "Iniciar Navegación": Oculto

### Estado 3: Calculando
- Dropdown: Deshabilitado
- Botón "Calcular Ruta": Oculto
- Loading spinner: Visible ⏳
- Botón "Iniciar Navegación": Oculto

### Estado 4: Ruta Calculada
- Dropdown: Habilitado
- Botón "Calcular Ruta": Oculto
- Vista recorrido: Visible con datos ✅
- Botón "Iniciar Navegación": Visible ✅

## Ventajas del Nuevo Flujo

✅ **UX Mejorada**: El usuario ve exactamente dónde está y a dónde puede ir  
✅ **Autonomía**: Usuario decide el destino, no el sistema  
✅ **Transparencia**: Se muestra la ruta completa antes de iniciar  
✅ **Información**: Distancia y número de pasos visibles  
✅ **Confianza**: Usuario puede revisar el recorrido paso a paso  
✅ **Cancelación**: Fácil de cancelar en cualquier momento  
✅ **Visual**: Iconos y colores mejoran comprensión  
✅ **Profesional**: Interfaz moderna y pulida  

## Casos de Uso Principales

### Caso 1: Estudiante busca aula
```
Estudiante escanea QR en entrada 🚪
→ Ve "Entrada 1" como origen
→ Busca en dropdown "Aula A101"
→ Calcula ruta
→ Ve 7 pasos con nombres claros
→ Inicia navegación
→ Sigue línea azul en el mapa 🗺️
```

### Caso 2: Visitante busca oficina
```
Visitante escanea QR en pasillo 🚶
→ Ve "Pasillo Central" como origen
→ Busca "Oficina Decanato" en dropdown
→ Calcula ruta
→ Revisa distancia (150 unidades)
→ Decide si ir o buscar alternativa
```

### Caso 3: Estudiante explora edificio
```
Estudiante en patio 🌳
→ Escanea QR del patio
→ Abre dropdown
→ Ve todos los lugares disponibles
→ Descubre "Cafetería" 
→ Calcula ruta
→ Sigue indicaciones
```

---

**Creado**: 15 de diciembre de 2025  
**Implementación**: ✅ Completa  
**Estado**: 🚀 Lista para pruebas
