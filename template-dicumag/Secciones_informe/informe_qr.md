# Informe: Implementación y Uso del Sistema de Códigos QR en la Aplicación de Navegación UMAG

## 1. Introducción

El sistema de **códigos QR** implementado en la aplicación de navegación interna UMAG permite a los usuarios identificar rápidamente ubicaciones, nodos del grafo, rutas completas e incluso coordenadas específicas dentro de los mapas SVG.  
Este módulo mejora la experiencia de navegación y agiliza el acceso a información relevante dentro de la facultad.

---

## 2. Objetivos de la Implementación

La integración de códigos QR cumple tres objetivos principales:

1. **Identificación rápida de ubicaciones** sin necesidad de buscar manualmente en el mapa.  
2. **Facilitar la navegación automática** hacia salas, oficinas, laboratorios o puntos de interés.  
3. **Compatibilidad con diversos formatos**, permitiendo flexibilidad tanto operativa como en la fase de depuración.

---

## 3. Arquitectura del Sistema QR

El sistema se compone de tres módulos esenciales:

### ✓ 3.1. `QRScannerScreen` (pantalla_lectora_qr.dart)

Pantalla encargada de:

- Activar la cámara.
- Detectar códigos QR en tiempo real.
- Validar y enviar los datos escaneados.
- Proveer controles como flash, pausa y vista previa.

---

### ✓ 3.2. `QRUtils` (codigo_qr.dart)

Este módulo centraliza la **lógica completa de interpretación y generación** de códigos QR.

**Tipos de códigos soportados:**

| Formato | Ejemplo | Uso |
|--------|---------|-----|
| `nodo:` | nodo:P1_Entrada_1 | Selección directa de nodos |
| `ruta:` | ruta:P1_A|P1_B | Cálculo de ruta con A* |
| `piso:` | piso:1|nodo:P1_Entrada_1 | Navegación entre pisos |
| `coord:` | coord:900,350 | Posicionamiento en SVG |
| `ubicacion:` | ubicacion:Ascensor | Alias amigables |

Funciones clave:

- `parseQRCode()`
- `esQRValido()`
- `procesarQRConGrafo()`
- Conversiones de alias ↔ ID
- Generación de QR dinámicos

---

### ✓ 3.3. `QRNavigation` (navegacion_qr.dart)

Define la **reacción de la app** ante cada tipo de QR procesado:

- Mostrar nodo.
- Calcular rutas con A*.
- Mostrar coordenadas.
- Navegar automáticamente entre pantallas.

---

## 4. Flujo de Funcionamiento

### 1. El usuario abre el lector QR  
La app crea una instancia de `QRScannerScreen` con el piso y grafo actual.

### 2. Se lee un QR  
El contenido escaneado se envía a `parseQRCode()`.

### 3. Validación de formato  
Si el QR es soportado, se procede; de lo contrario, se avisa al usuario.

### 4. Interpretación del contenido  
Según el tipo de QR, se extraen:

- IDs de nodos  
- Pisos  
- Alias  
- Coordenadas  
- Rutas  

### 5. Procesamiento  
`procesarQRConGrafo()` implementa lógica adicional, como:

- Buscar nodos en el grafo  
- Calcular rutas usando A*  
- Determinar distancias  
- Convertir coordenadas  

### 6. Acción final en la interfaz  
Usando `QRNavigation`, la app:

- Regresa al mapa  
- Selecciona nodos  
- Muestra rutas  
- Centra el mapa  
- Inicia navegación paso a paso  

---

## 5. Ejemplos de Uso

### Escanear nodo:
```
nodo:P1_Entrada_1
```
Selecciona automáticamente la entrada del piso 1.

### Escanear ruta:
```
ruta:P1_Entrada_1|P1_Lab_Tesla
```
Acciones:

1. Calcular ruta con A*.  
2. Mostrar pasos.  
3. Iniciar navegación.  

### Escanear coordenadas:
```
coord:1020,540
```
Centra el mapa en la posición indicada.

### Escanear alias:
```
ubicacion:Ascensor
```
La app lo interpreta como `P1_Ascensor`.

---

## 6. Generación de Códigos QR

En modo debug, desde el mapa:

- Tocar un nodo → “Generar QR”
- Se copia al portapapeles un QR válido para ese nodo.

Ejemplos generados automáticamente:

```
piso:1|nodo:P1_Pasillo_3
coord:850,420
ruta:P1_Entrada_1|P1_Sala_Magister_comp
```

---

## 7. Ventajas del Sistema QR

- Navegación más rápida dentro del edificio.
- Integración completa con el grafo y A*.
- Soporte para mapas complejos con coordenadas.
- Señalización física dentro de la facultad.
- Simplificación del debugging del sistema.

---

## 8. Conclusión

El sistema de códigos QR dota a la aplicación de una funcionalidad moderna, robusta y muy útil tanto para usuarios como para desarrolladores.  
Permite una navegación precisa, rápida y flexible dentro del campus, y está preparado para futuras extensiones como navegación aumentada o geolocalización interna avanzada.

---

