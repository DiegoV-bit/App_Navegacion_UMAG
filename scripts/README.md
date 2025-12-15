# Scripts de Generación de Códigos QR

Este directorio contiene los scripts de Python para generar códigos QR del sistema de navegación interior.

## 📋 Archivos

```
scripts/
├── generar_qrs.py          Script principal - Genera QRs de todos los pisos
├── generar_qr_piso.py      Script auxiliar - Genera QRs de un piso específico
└── requirements.txt        Dependencias de Python necesarias
```

## 🚀 Instalación Rápida

### 1. Instalar dependencias

```bash
pip install -r requirements.txt
```

O manualmente:

```bash
pip install qrcode[pil] Pillow
```

### 2. Verificar instalación

```bash
python -c "import qrcode; print('✓ qrcode instalado')"
python -c "from PIL import Image; print('✓ Pillow instalado')"
```

## 📖 Uso

### Generar todos los QRs (Recomendado)

```bash
# Desde el directorio raíz del proyecto
python scripts/generar_qrs.py
```

**Salida:**
- `qr_codes/piso1/` - 50 QRs del piso 1
- `qr_codes/piso2/` - 24 QRs del piso 2
- `qr_codes/piso3/` - 22 QRs del piso 3
- `qr_codes/piso4/` - 12 QRs del piso 4

### Generar QRs de un piso específico

```bash
# Solo piso 1
python scripts/generar_qr_piso.py 1

# Solo piso 3
python scripts/generar_qr_piso.py 3
```

## 🔧 Configuración

### Calidad del QR

En `generar_qrs.py`, líneas 21-27:

```python
QR_CONFIG = {
    'version': 1,              # Tamaño del QR (1-40, auto ajusta)
    'error_correction': qrcode.constants.ERROR_CORRECT_H,  # Nivel de corrección
    'box_size': 10,            # Tamaño de cada caja en píxeles
    'border': 4,               # Tamaño del borde
}
```

### Niveles de corrección de errores

| Nivel | Constante | Corrección | Uso recomendado |
|-------|-----------|------------|------------------|
| L     | `ERROR_CORRECT_L` | ~7%  | QRs en interiores limpios |
| M     | `ERROR_CORRECT_M` | ~15% | Uso general |
| Q     | `ERROR_CORRECT_Q` | ~25% | Ambientes con suciedad |
| H     | `ERROR_CORRECT_H` | ~30% | **Recomendado** - Máxima durabilidad |

### Tamaño de imagen

Para cambiar el tamaño de salida:

```python
IMAGE_CONFIG = {
    'fill_color': 'black',
    'back_color': 'white',
}

# Cambiar box_size para ajustar el tamaño final:
# box_size = 5  → ~100x100 px (para preview)
# box_size = 10 → ~200x200 px (actual)
# box_size = 20 → ~400x400 px (impresión alta calidad)
```

## 📊 Formato de Datos

Cada QR contiene un JSON con esta estructura:

```json
{
  "type": "nodo",
  "id": "P1_Entrada_1",
  "piso": 1,
  "x": 1004,
  "y": 460
}
```

**Campos:**
- `type`: Siempre "nodo" para ubicaciones
- `id`: Identificador único del nodo (del archivo `grafo_pisoN.json`)
- `piso`: Número de piso extraído del ID o del archivo
- `x`, `y`: Coordenadas SVG del nodo

## 🐛 Solución de Problemas

### Error: "No module named 'qrcode'"

```bash
pip install qrcode[pil]
```

### Error: "No module named 'PIL'"

```bash
pip install Pillow
```

### Error: "Archivo no encontrado: grafo_pisoN.json"

Verifica que los archivos existan en:
```
lib/data/grafo_piso1.json
lib/data/grafo_piso2.json
lib/data/grafo_piso3.json
lib/data/grafo_piso4.json
```

### Los QRs no se ven bien al imprimir

1. Aumenta el `box_size` a 15 o 20
2. Imprime en alta resolución (300+ DPI)
3. Usa impresora láser para mejor contraste

## 🔄 Regenerar QRs

### Cuándo regenerar

- ✅ Después de modificar los archivos JSON del grafo
- ✅ Si agregaste nuevos nodos
- ✅ Si cambiaste coordenadas de nodos existentes
- ✅ Si el QR físico está dañado
- ⚠️ No es necesario si solo cambias conexiones

### Proceso de regeneración

1. **Modifica el grafo:**
   ```bash
   # Edita: lib/data/grafo_piso1.json
   ```

2. **Regenera los QRs:**
   ```bash
   python scripts/generar_qrs.py
   ```

3. **Verifica los cambios:**
   ```bash
   # Comprueba que se generaron correctamente
   ls qr_codes/piso1/
   ```

4. **Imprime e instala:**
   - Solo imprime los QRs que cambiaron
   - Reemplaza los stickers físicos

## 📐 Personalización Avanzada

### Agregar logo en el centro del QR

```python
# En generar_qrs.py, función generar_qr_imagen():

from PIL import Image

# Después de crear el QR:
img = qr.make_image(**IMAGE_CONFIG)

# Agregar logo
logo = Image.open('logo_umag.png')
logo = logo.resize((50, 50))  # Ajustar tamaño

# Calcular posición centrada
pos = ((img.size[0] - logo.size[0]) // 2,
       (img.size[1] - logo.size[1]) // 2)

img.paste(logo, pos)
```

### Cambiar colores del QR

```python
IMAGE_CONFIG = {
    'fill_color': '#003366',  # Azul UMAG
    'back_color': 'white',
}
```

### Generar QRs de mayor resolución

```python
QR_CONFIG = {
    'version': 1,
    'error_correction': qrcode.constants.ERROR_CORRECT_H,
    'box_size': 20,  # Mayor resolución
    'border': 6,     # Borde más grande
}
```

## 📝 Ejemplos de Uso

### Ejemplo 1: Generar solo piso 2

```bash
cd scripts
python generar_qr_piso.py 2
```

**Salida esperada:**
```
======================================================================
🗺️  REGENERAR QRs - PISO 2
======================================================================
📍 Generando QRs para 24 nodos del piso 2...
✅ 24 códigos QR regenerados correctamente
```

### Ejemplo 2: Generar todos y verificar

```bash
# Generar
python scripts/generar_qrs.py

# Verificar cantidad
ls qr_codes/piso1/ | wc -l  # Linux/Mac
(Get-ChildItem qr_codes/piso1/).Count  # PowerShell
```

### Ejemplo 3: Regenerar después de actualizar grafo

```bash
# 1. Editar grafo
nano lib/data/grafo_piso1.json

# 2. Regenerar QRs
python scripts/generar_qrs.py

# 3. Ver cambios
git status qr_codes/
```

## 🔗 Integración con la App

Los QRs generados son compatibles con la lectura en:
- [`lib/utils/codigo_qr.dart`](../lib/utils/codigo_qr.dart)
- [`lib/utils/pantalla_lectora_qr.dart`](../lib/utils/pantalla_lectora_qr.dart)

El formato es el mismo que usa `QRUtils.generarQRParaNodo()` en Dart.

## 📞 Soporte

Si tienes problemas o preguntas:

1. Revisa la sección **Solución de Problemas** arriba
2. Verifica los logs de error del script
3. Contacta al equipo de desarrollo

## 📜 Licencia

Este script es parte del Sistema de Navegación Interior de la Universidad de Magallanes.

---

**Última actualización:** Diciembre 2025  
**Versión:** 1.0  
**Python requerido:** 3.7+
