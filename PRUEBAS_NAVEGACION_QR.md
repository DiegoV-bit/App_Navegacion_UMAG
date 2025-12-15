# ✅ Checklist de Pruebas - Sistema de Navegación con QR

## 📋 Preparación

- [ ] Compilar aplicación sin errores
- [ ] Tener códigos QR impresos o en pantalla
- [ ] Dispositivo móvil con cámara funcional
- [ ] Buena iluminación para escanear QR

## 🧪 Pruebas Funcionales

### 1. Escaneo de QR ✅

#### Test 1.1: Escaneo básico
- [ ] Abrir mapa de Piso 1
- [ ] Presionar botón "Escanear QR"
- [ ] Cámara se abre correctamente
- [ ] Escanear QR de `P1_Entrada_1`
- [ ] QR es detectado (scanner se detiene)
- [ ] Se abre PantallaSeleccionDestino

**Resultado Esperado**: Pantalla muestra "Entrada 1" como ubicación actual

#### Test 1.2: Validación de formato
- [ ] Escanear QR con formato JSON: `{"type":"nodo","id":"P1_Pasillo_1",...}`
- [ ] QR es aceptado
- [ ] Pantalla de selección se abre correctamente

**Resultado Esperado**: QR JSON funciona igual que formatos legacy

#### Test 1.3: QR inválido
- [ ] Escanear código QR aleatorio (no de la app)
- [ ] Se muestra mensaje: "Formato QR no soportado"
- [ ] Scanner permanece abierto

**Resultado Esperado**: Error claro, sin crash

### 2. Pantalla de Selección de Destino 🎯

#### Test 2.1: Información del origen
- [ ] Verificar que muestra nombre amigable (no ID técnico)
- [ ] Verificar que muestra piso correcto
- [ ] Verificar diseño visual (gradiente azul, texto blanco)

**Resultado Esperado**: Información clara y legible

#### Test 2.2: Dropdown de destinos
- [ ] Presionar dropdown
- [ ] Verificar que se abre lista completa
- [ ] Confirmar que solo aparecen nodos del mismo piso
- [ ] Confirmar que el origen NO aparece en la lista
- [ ] Verificar iconos contextuales (🚪, 🚶, 🔬, etc.)

**Resultado Esperado**: Lista ordenada con ~49 opciones (para Piso 1)

#### Test 2.3: Selección de destino
- [ ] Seleccionar "Aula A101" (o similar)
- [ ] Dropdown muestra el valor seleccionado
- [ ] Aparece botón "Calcular Ruta"

**Resultado Esperado**: UI responde inmediatamente

### 3. Cálculo de Ruta 🧮

#### Test 3.1: Ruta exitosa (distancia corta)
- [ ] Origen: `P1_Entrada_1`
- [ ] Destino: `P1_Pasillo_Central`
- [ ] Presionar "Calcular Ruta"
- [ ] Aparece loading spinner
- [ ] Se muestra resultado en <2 segundos
- [ ] Verificar número de pasos (debería ser 2-4)
- [ ] Verificar distancia calculada

**Resultado Esperado**: Ruta directa, pocos pasos

#### Test 3.2: Ruta exitosa (distancia larga)
- [ ] Origen: `P1_Entrada_1`
- [ ] Destino: nodo al otro extremo del piso
- [ ] Presionar "Calcular Ruta"
- [ ] Verificar número de pasos (debería ser 8-15)
- [ ] Verificar que distancia es mayor

**Resultado Esperado**: Ruta más larga pero óptima

#### Test 3.3: Ruta imposible
- [ ] Modificar grafo temporalmente (quitar conexiones)
- [ ] Intentar calcular ruta entre nodos desconectados
- [ ] Verificar mensaje de error

**Resultado Esperado**: "No se encontró una ruta entre estos puntos"

### 4. Visualización del Recorrido 📊

#### Test 4.1: Lista de pasos
- [ ] Verificar numeración secuencial (1, 2, 3...)
- [ ] Paso 1 tiene color verde 🟢
- [ ] Paso final tiene color rojo 🔴
- [ ] Pasos intermedios tienen color azul 🔵
- [ ] Nombres son legibles y amigables

**Resultado Esperado**: Lista clara y fácil de seguir

#### Test 4.2: Información adicional
- [ ] Verificar que muestra distancia total
- [ ] Verificar que muestra número de pasos
- [ ] Formato de distancia: "150.5 unidades"

**Resultado Esperado**: Datos precisos y bien formateados

#### Test 4.3: Scroll de lista
- [ ] Con ruta larga (>10 pasos)
- [ ] Verificar que lista es scrollable
- [ ] Todos los pasos son visibles

**Resultado Esperado**: Lista completa navegable

### 5. Navegación al Mapa 🗺️

#### Test 5.1: Iniciar navegación
- [ ] Después de calcular ruta
- [ ] Presionar "Iniciar Navegación"
- [ ] Pantalla de selección se cierra
- [ ] Scanner también se cierra
- [ ] Regresa al mapa
- [ ] Ruta se visualiza en el mapa

**Resultado Esperado**: Transición suave, ruta visible

#### Test 5.2: Visualización en mapa
- [ ] Líneas conectan los nodos de la ruta
- [ ] Colores distintivos (azul/verde)
- [ ] Animaciones fluidas
- [ ] Nodos de ruta destacados

**Resultado Esperado**: Ruta claramente visible sobre el mapa SVG

#### Test 5.3: Notificación
- [ ] Aparece SnackBar en parte inferior
- [ ] Mensaje: "Ruta calculada: X pasos"
- [ ] Color verde
- [ ] Botón "Ver" (opcional)
- [ ] Se oculta después de 3-4 segundos

**Resultado Esperado**: Feedback claro al usuario

### 6. Cancelaciones y Navegación ↩️

#### Test 6.1: Cancelar desde scanner
- [ ] Abrir scanner
- [ ] Presionar botón X rojo
- [ ] Regresa al mapa
- [ ] Sin cambios en el estado

**Resultado Esperado**: Cancelación limpia

#### Test 6.2: Cancelar desde selección de destino
- [ ] Escanear QR
- [ ] En pantalla de selección, presionar back/flecha
- [ ] Regresa al mapa
- [ ] Sin crash, sin errores

**Resultado Esperado**: Navegación hacia atrás funciona

#### Test 6.3: Cambiar destino sin calcular ruta
- [ ] Seleccionar destino A
- [ ] Seleccionar destino B (sin calcular)
- [ ] Calcular ruta
- [ ] Ruta es hacia destino B

**Resultado Esperado**: Cambio de destino respetado

### 7. Múltiples Pisos 🏢

#### Test 7.1: Piso 1
- [ ] Escanear QR de P1_*
- [ ] Dropdown muestra ~50 nodos
- [ ] Calcular ruta
- [ ] Todo funciona correctamente

#### Test 7.2: Piso 2
- [ ] Cambiar a mapa Piso 2
- [ ] Escanear QR de P2_*
- [ ] Dropdown muestra ~24 nodos
- [ ] Calcular ruta
- [ ] Todo funciona correctamente

#### Test 7.3: Piso 3
- [ ] Cambiar a mapa Piso 3
- [ ] Escanear QR de P3_*
- [ ] Dropdown muestra ~22 nodos
- [ ] Calcular ruta
- [ ] Todo funciona correctamente

#### Test 7.4: Piso 4
- [ ] Cambiar a mapa Piso 4
- [ ] Escanear QR de P4_*
- [ ] Dropdown muestra ~12 nodos
- [ ] Calcular ruta
- [ ] Todo funciona correctamente

**Resultado Esperado**: Sistema funciona en todos los pisos

### 8. Rendimiento ⚡

#### Test 8.1: Tiempo de cálculo
- [ ] Medir tiempo desde "Calcular Ruta" hasta resultado
- [ ] Debería ser <2 segundos para rutas normales
- [ ] Debería ser <5 segundos para rutas complejas

**Resultado Esperado**: Respuesta rápida y fluida

#### Test 8.2: Uso de memoria
- [ ] Escanear varios QR seguidos (5-10 veces)
- [ ] Verificar que app no se ralentiza
- [ ] Verificar que no hay leaks de memoria

**Resultado Esperado**: Rendimiento constante

#### Test 8.3: Batería
- [ ] Usar scanner durante 5 minutos
- [ ] Verificar consumo de batería razonable
- [ ] Cámara se apaga al cerrar scanner

**Resultado Esperado**: Sin consumo excesivo

## 🎨 Pruebas de UI/UX

### Test UI-1: Diseño visual
- [ ] Colores consistentes con tema de la app
- [ ] Textos legibles (tamaño adecuado)
- [ ] Iconos claros y descriptivos
- [ ] Espaciado apropiado entre elementos

**Resultado Esperado**: Interfaz profesional y pulida

### Test UI-2: Responsividad
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Probar orientación vertical
- [ ] Probar orientación horizontal
- [ ] Elementos se adaptan correctamente

**Resultado Esperado**: Funciona en todas las resoluciones

### Test UI-3: Accesibilidad
- [ ] Textos tienen buen contraste
- [ ] Botones tienen tamaño táctil adecuado (>44px)
- [ ] Nombres descriptivos para lectores de pantalla

**Resultado Esperado**: Usable para todos

## 🐛 Pruebas de Casos Edge

### Test Edge-1: Sin permisos de cámara
- [ ] Negar permisos de cámara
- [ ] Intentar abrir scanner
- [ ] Verificar mensaje de error apropiado

**Resultado Esperado**: Error claro, sin crash

### Test Edge-2: Cámara en uso
- [ ] Abrir otra app que use cámara
- [ ] Intentar abrir scanner
- [ ] Verificar manejo del error

**Resultado Esperado**: Mensaje informativo

### Test Edge-3: Grafo corrupto
- [ ] Modificar JSON del grafo (hacer inválido)
- [ ] Intentar abrir scanner
- [ ] Verificar error controlado

**Resultado Esperado**: No crash, mensaje de error

### Test Edge-4: QR muy dañado
- [ ] QR con parte borrada/dañada
- [ ] Intentar escanear
- [ ] Verificar corrección de errores (ERROR_CORRECT_H)

**Resultado Esperado**: QR se lee si daño <30%

### Test Edge-5: Iluminación extrema
- [ ] Lugar muy oscuro
- [ ] Lugar muy brillante
- [ ] Verificar funcionalidad del flash
- [ ] Verificar ajuste automático de cámara

**Resultado Esperado**: Scanner adaptable

## 📊 Reporte de Resultados

### Formato de Reporte

```
Prueba: [Nombre del Test]
Estado: [✅ PASS / ❌ FAIL / ⚠️ PARCIAL]
Descripción: [Breve descripción del resultado]
Observaciones: [Notas adicionales]
Screenshot: [Opcional]
```

### Ejemplo

```
Prueba: Test 3.1 - Ruta exitosa (distancia corta)
Estado: ✅ PASS
Descripción: Ruta calculada en 0.8s, 3 pasos, distancia 45.2 unidades
Observaciones: Animación fluida, UI responsive
Screenshot: [adjunto]
```

## 🎯 Criterios de Aceptación

Para considerar la funcionalidad completa y lista para producción:

- ✅ Todos los tests funcionales pasan (1-5)
- ✅ Al menos 95% de tests de múltiples pisos pasan (7)
- ✅ Rendimiento aceptable en todos los tests (8)
- ✅ UI/UX cumple estándares (UI-1 a UI-3)
- ✅ Sin crashes en casos edge críticos (Edge-1 a Edge-5)

## 🚀 Próximos Pasos después de Pruebas

1. [ ] Documentar bugs encontrados
2. [ ] Priorizar correcciones
3. [ ] Implementar mejoras sugeridas
4. [ ] Ejecutar regresión
5. [ ] Deploy a producción

---

**Fecha de Creación**: 15 de diciembre de 2025  
**Versión**: 1.0  
**Responsable**: Equipo de Desarrollo UMAG
