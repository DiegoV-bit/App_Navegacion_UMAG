# Creación de los Códigos QR

## Introducción

Para la implementación del sistema de navegación interior, se desarrolló un programa en Python que automatiza la generación de códigos QR para cada nodo definido en los grafos de navegación. Este sistema permite generar de forma rápida y consistente todos los códigos QR necesarios para los 4 pisos de la Facultad de Ingeniería, facilitando el despliegue físico del sistema.

## Arquitectura del Sistema de Generación

El sistema de generación de códigos QR está compuesto por tres scripts principales ubicados en el directorio `scripts/`:

### 1. `generar_qrs.py` - Script Principal

Este es el script principal que genera códigos QR para todos los pisos del edificio de forma automatizada.

**Características principales:**
- Generación masiva de QRs para todos los pisos
- Lectura automática de archivos JSON de grafos
- Creación de estructura de carpetas organizada
- Estadísticas detalladas de generación
- Generación automática de documentación README

### 2. `generar_qr_piso.py` - Script Auxiliar

Script de utilidad para regenerar códigos QR de un piso específico, útil durante el desarrollo y mantenimiento.

**Uso:**
```bash
python generar_qr_piso.py [número_piso]
```

### 3. `verificar_formato_qr.py` - Verificador de Formato

Script de pruebas que valida que los QRs generados sean compatibles con el formato esperado por la aplicación Flutter.

## Dependencias del Sistema

El sistema utiliza las siguientes bibliotecas de Python, definidas en `requirements.txt`:

### `qrcode[pil]==8.2`
Biblioteca principal para la generación de códigos QR. Proporciona:
- Soporte para diferentes versiones de QR (1-40)
- Múltiples niveles de corrección de errores (L, M, Q, H)
- Personalización de tamaño y borde
- Exportación a múltiples formatos de imagen

### `Pillow>=11.0.0`
Biblioteca de procesamiento de imágenes (PIL - Python Imaging Library). Se utiliza para:
- Renderización de códigos QR en formato PNG
- Manipulación de colores y contraste
- Configuración de la calidad de salida
- Soporte para diferentes formatos de imagen

## Estructura del Código Principal

### Configuración Inicial

```python
# Configuración de generación de QR
QR_CONFIG = {
    'version': 1,  
    'error_correction': qrcode.constants.ERROR_CORRECT_H,
    'box_size': 10,
    'border': 4,
}
```

**Parámetros explicados:**

- **`version: 1`**: Define el tamaño del QR. Versión 1 es el QR más pequeño posible (21x21 módulos), que se ajusta automáticamente si el contenido es mayor.

- **`error_correction: ERROR_CORRECT_H`**: Nivel de corrección de errores al 30%. Este nivel permite que el QR funcione incluso si está parcialmente dañado, sucio o deteriorado, ideal para instalaciones físicas en ambientes educativos.

- **`box_size: 10`**: Tamaño en píxeles de cada módulo del QR. Con 10 píxeles, un QR versión 1 genera una imagen de aproximadamente 290x290 píxeles.

- **`border: 4`**: Tamaño del borde en módulos. El estándar QR requiere mínimo 4 módulos de borde para garantizar el escaneo correcto.

### Funciones Principales del Sistema

#### 1. `leer_grafo_json(ruta_json)`

Lee y valida archivos JSON de grafos de navegación.

**Validaciones implementadas:**
- Existencia del archivo
- Formato JSON válido
- Presencia de la clave 'nodos'
- Manejo robusto de errores con mensajes descriptivos

**Código relevante:**
```python
def leer_grafo_json(ruta_json):
    try:
        with open(ruta_json, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'nodos' not in data:
            print(f"⚠️  El archivo no contiene la clave 'nodos': {ruta_json}")
            return None
            
        return data
    except FileNotFoundError:
        print(f"❌ Archivo no encontrado: {ruta_json}")
        return None
    except json.JSONDecodeError as e:
        print(f"❌ Error al decodificar JSON: {e}")
        return None
```

**Propósito:** Garantizar que solo se procesen archivos JSON válidos y completos, evitando errores durante la generación masiva.

#### 2. `extraer_numero_piso(nodo_id)`

Extrae el número de piso del identificador del nodo siguiendo la convención de nomenclatura del proyecto.

**Formato esperado:** `P{numero}_{descripcion}` (ejemplo: `P1_Entrada_1`)

```python
def extraer_numero_piso(nodo_id):
    try:
        if '_' in nodo_id and nodo_id.startswith('P'):
            piso_str = nodo_id.split('_')[0].replace('P', '')
            return int(piso_str)
    except (ValueError, IndexError):
        pass
    
    return 1  # Piso por defecto
```

**Importancia:** Permite que los códigos QR contengan información del piso sin necesidad de configuración manual, facilitando la navegación multi-piso.

#### 3. `crear_datos_qr(nodo, piso_default)`

Genera el contenido JSON que será codificado en cada código QR.

**Formato de salida:**
```json
{
  "type": "nodo",
  "id": "P1_Entrada_1",
  "piso": 1,
  "x": 1004,
  "y": 460
}
```

**Campos del QR:**
- **`type`**: Identifica el tipo de QR (`"nodo"` para ubicaciones físicas)
- **`id`**: Identificador único del nodo en el sistema
- **`piso`**: Número de piso extraído del ID
- **`x`, y`**: Coordenadas del nodo en el sistema SVG

**Código:**
```python
def crear_datos_qr(nodo, piso_default=1):
    nodo_id = nodo.get('id', '')
    piso = extraer_numero_piso(nodo_id) if nodo_id else piso_default
    
    qr_data = {
        "type": "nodo",
        "id": nodo_id,
        "piso": piso,
        "x": nodo.get('x'),
        "y": nodo.get('y')
    }
    
    return json.dumps(qr_data, ensure_ascii=False)
```

**Nota técnica:** El parámetro `ensure_ascii=False` permite que caracteres especiales (tildes, ñ) se mantengan en UTF-8, importante para nombres en español.

#### 4. `generar_qr_imagen(datos_qr, ruta_salida)`

Genera la imagen PNG del código QR con la configuración especificada.

```python
def generar_qr_imagen(datos_qr, ruta_salida):
    try:
        # Crear objeto QR con configuración
        qr = qrcode.QRCode(**QR_CONFIG)
        qr.add_data(datos_qr)
        qr.make(fit=True)
        
        # Generar imagen en blanco y negro
        img = qr.make_image(**IMAGE_CONFIG)
        
        # Guardar en formato PNG
        img.save(ruta_salida)
        return True
        
    except Exception as e:
        print(f"❌ Error generando QR: {e}")
        return False
```

**Proceso interno:**
1. Crea un objeto QRCode con la configuración predefinida
2. Agrega los datos JSON al código
3. Optimiza el tamaño con `fit=True`
4. Genera la imagen en blanco y negro puro
5. Guarda en formato PNG comprimido

#### 5. `generar_qrs_desde_grafo(ruta_json, carpeta_salida, numero_piso)`

Función principal que coordina la generación masiva de QRs para un piso completo.

**Proceso:**
```
1. Leer archivo JSON del grafo
2. Extraer lista de nodos
3. Crear carpeta de salida (ej: qr_codes/piso1/)
4. Iterar sobre cada nodo:
   a. Crear datos JSON del QR
   b. Generar nombre de archivo (QR_P1_Entrada_1.png)
   c. Generar imagen QR
   d. Reportar progreso cada 10 nodos
5. Mostrar estadísticas finales
```

**Salida en consola:**
```
📍 Generando QRs para 50 nodos del piso 1...
📂 Guardando en: /path/to/qr_codes/piso1
──────────────────────────────────────────────────────────────────────
  [ 10/ 50] ✓ QR_P1_Entrada_1.png
  [ 20/ 50] ✓ QR_P1_Pasillo_Norte.png
  [ 30/ 50] ✓ QR_P1_Lab_Fisica.png
  [ 40/ 50] ✓ QR_P1_Escalera_Centro.png
  [ 50/ 50] ✓ QR_P1_Baños_ciencias.png
──────────────────────────────────────────────────────────────────────
✅ Completado: 50 QRs generados correctamente
```

#### 6. `generar_qrs_todos_los_pisos(directorio_base)`

Función de orquestación que genera códigos QR para todos los pisos del edificio.

**Configuración de pisos:**
```python
configuracion_pisos = [
    (1, 'lib/data/grafo_piso1.json', 'qr_codes/piso1'),
    (2, 'lib/data/grafo_piso2.json', 'qr_codes/piso2'),
    (3, 'lib/data/grafo_piso3.json', 'qr_codes/piso3'),
    (4, 'lib/data/grafo_piso4.json', 'qr_codes/piso4'),
]
```

**Salida completa del proceso:**
```
======================================================================
🗺️  GENERADOR DE CÓDIGOS QR - NAVEGACIÓN UMAG
======================================================================
📅 Fecha: 2025-12-18 10:30:45
📂 Directorio base: /path/to/App_Navegacion_UMAG
======================================================================

📍 Generando QRs para 50 nodos del piso 1...
✅ Completado: 50 QRs generados correctamente

📍 Generando QRs para 24 nodos del piso 2...
✅ Completado: 24 QRs generados correctamente

📍 Generando QRs para 22 nodos del piso 3...
✅ Completado: 22 QRs generados correctamente

📍 Generando QRs para 12 nodos del piso 4...
✅ Completado: 12 QRs generados correctamente

======================================================================
📊 RESUMEN DE GENERACIÓN
======================================================================
  Piso 1:  50 QRs generados
  Piso 2:  24 QRs generados
  Piso 3:  22 QRs generados
  Piso 4:  12 QRs generados
──────────────────────────────────────────────────────────────────────
  TOTAL: 108 códigos QR generados
======================================================================

✅ Proceso completado exitosamente

📌 PRÓXIMOS PASOS:
   1. Revisa los QRs generados en la carpeta 'qr_codes/'
   2. Imprime los QRs en stickers de 5x5 cm
   3. Coloca los QRs a 1.5m de altura en cada ubicación
   4. Prueba el escaneo con la aplicación móvil

💡 TIP: Los QRs tienen corrección de errores nivel H (30%)
   Esto permite que funcionen incluso con daños menores.
```

## Especificaciones Técnicas del QR

### Características de los Códigos Generados

| Característica | Valor | Justificación |
|----------------|-------|---------------|
| **Versión QR** | 1 (auto-ajusta) | Mínimo tamaño posible, óptimo para datos pequeños |
| **Corrección de Errores** | Nivel H (30%) | Máxima durabilidad en ambientes de alto tráfico |
| **Tamaño de Imagen** | ~290x290 px | Suficiente para impresión a 5x5 cm con 300 DPI |
| **Formato de Archivo** | PNG | Compresión sin pérdida, ideal para impresión |
| **Colores** | Blanco y Negro | Máximo contraste para lectura confiable |
| **Tamaño de Datos** | ~80-120 bytes | JSON compacto con información esencial |

### Nivel de Corrección de Errores H

El nivel H permite recuperar hasta el **30% de la información** del código aunque esté dañada. Esto es crítico porque:

1. **Desgaste físico:** Los stickers pueden rayarse o deteriorarse
2. **Suciedad:** Acumulación de polvo o manchas
3. **Condiciones de luz:** Reflejo o sombras durante el escaneo
4. **Impresión imperfecta:** Variaciones en la calidad de impresión

## Integración con la Aplicación Flutter

Los códigos QR generados son totalmente compatibles con el módulo `codigo_qr.dart` de la aplicación:

### Lectura en la Aplicación

```dart
// Formato JSON leído por QRUtils.decodificarQR()
{
  "type": "nodo",      // Tipo de QR
  "id": "P1_Entrada_1", // ID del nodo
  "piso": 1,           // Número de piso
  "x": 1004,           // Coordenada X
  "y": 460             // Coordenada Y
}
```

### Proceso de Escaneo

1. Usuario escanea QR con `PantallaLectoraQR`
2. Sistema decodifica JSON con `QRUtils.decodificarQR()`
3. Extrae el ID del nodo y el piso
4. Carga el grafo correspondiente
5. Posiciona al usuario en el nodo escaneado
6. Permite seleccionar destino y calcular ruta

## Instrucciones de Uso

### Instalación de Dependencias

```bash
# Navegar al directorio de scripts
cd scripts

# Instalar dependencias
pip install -r requirements.txt
```

### Generación de Todos los QRs

```bash
# Desde el directorio raíz del proyecto
python scripts/generar_qrs.py
```

### Regeneración de un Piso Específico

```bash
# Solo regenerar piso 1
python scripts/generar_qr_piso.py 1

# Solo regenerar piso 3
python scripts/generar_qr_piso.py 3
```

### Verificación de Formato

```bash
# Verificar que los QRs sean compatibles
python scripts/verificar_formato_qr.py
```

## Estructura de Salida

Después de ejecutar el script, se genera la siguiente estructura:

```
qr_codes/
├── README.md           # Documentación automática
├── piso1/
│   ├── QR_P1_Entrada_1.png
│   ├── QR_P1_Pasillo_Norte.png
│   ├── QR_P1_Lab_Fisica.png
│   └── ... (50 archivos)
├── piso2/
│   ├── QR_P2_Escalera_Norte.png
│   └── ... (24 archivos)
├── piso3/
│   └── ... (22 archivos)
└── piso4/
    └── ... (12 archivos)
```

**Total:** 108 códigos QR organizados por piso

## Consideraciones de Implementación Física

### Especificaciones de Impresión

- **Tamaño recomendado:** 5x5 cm
- **Tamaño mínimo funcional:** 3x3 cm
- **Resolución:** 300 DPI o superior
- **Material:** Stickers vinilo plastificado (resistente al agua)
- **Impresora:** Láser preferiblemente (mejor contraste)

### Instalación

- **Altura estándar:** 1.5 metros desde el suelo
- **Ubicación:** Superficies planas, visibles y accesibles
- **Orientación:** Perpendicular a la línea de visión
- **Iluminación:** Evitar zonas con reflejo directo

### Mantenimiento

- **Limpieza:** Paño húmedo cada 3 meses
- **Inspección:** Verificar legibilidad mensualmente
- **Reemplazo:** Cambiar si el daño supera el 30%

## Ventajas del Sistema Automatizado

1. **Consistencia:** Todos los QRs siguen el mismo formato
2. **Escalabilidad:** Fácil agregar nuevos nodos
3. **Mantenibilidad:** Regeneración rápida tras cambios
4. **Trazabilidad:** Nomenclatura clara y organizada
5. **Calidad:** Configuración óptima para todos los QRs
6. **Documentación:** README automático con cada generación

## Conclusión

El sistema de generación automatizada de códigos QR desarrollado en Python constituye una pieza fundamental de la infraestructura del sistema de navegación interior. Su diseño modular, robusto y bien documentado facilita tanto el despliegue inicial como el mantenimiento continuo del sistema, garantizando la consistencia y calidad de todos los códigos QR utilizados en la Facultad de Ingeniería.