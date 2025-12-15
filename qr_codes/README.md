# Códigos QR - Sistema de Navegación UMAG

## 📋 Información General

Este directorio contiene **108 códigos QR** generados para el sistema de navegación interior de la Facultad de Ingeniería de la Universidad de Magallanes.

## 📁 Estructura de Carpetas

```
qr_codes/
├── piso1/          50 QRs del primer piso
├── piso2/          24 QRs del segundo piso
├── piso3/          22 QRs del tercer piso
└── piso4/          12 QRs del cuarto piso
```

## 🔍 Formato de Datos del QR

Cada código QR contiene información en formato JSON que la aplicación puede leer:

```json
{
  "type": "nodo",
  "id": "P1_Entrada_1",
  "piso": 1,
  "x": 100,
  "y": 200
}
```

**Campos:**
- `type`: Tipo de elemento (siempre "nodo" para ubicaciones)
- `id`: Identificador único del nodo
- `piso`: Número de piso (1-4)
- `x`, `y`: Coordenadas en el mapa SVG

## 📏 Especificaciones de Impresión

### Tamaños Recomendados

| Distancia de escaneo | Tamaño mínimo | Tamaño recomendado |
|---------------------|---------------|-------------------|
| 0.5 - 1 metro       | 3x3 cm        | 5x5 cm            |
| 1 - 2 metros        | 5x5 cm        | 8x8 cm            |
| 2 - 3 metros        | 8x8 cm        | 10x10 cm          |

### Material y Configuración

- **Material:** Stickers vinilo plastificado (resistente al agua y rayones)
- **Acabado:** Mate (evita reflejos de luz)
- **Impresora:** Láser o inyección de tinta de alta calidad
- **Resolución:** Mínimo 300 DPI
- **Colores:** Blanco y negro únicamente (negro #000000, blanco #FFFFFF)
- **Corrección de errores:** Nivel H (30% de corrección - muy resistente a daños)

### Configuración de Impresión

```
Papel: Adhesivo vinilo blanco brillante o mate
Tamaño: A4 (21 x 29.7 cm)
Disposición: 4 QRs por hoja (2x2)
Márgenes: 1 cm mínimo
Corte: Con guillotina o tijeras de precisión
```

## 📍 Guía de Instalación

### 1. Preparación

- [ ] Imprime los QRs en el material especificado
- [ ] Corta los stickers con margen de 5mm
- [ ] Limpia las superficies donde se instalarán
- [ ] Verifica que cada ubicación tenga buena iluminación

### 2. Colocación Correcta

**Altura estándar:** 1.5 metros desde el suelo (altura de lectura cómoda)

**Ubicaciones ideales:**
- Paredes lisas cerca de puertas
- Postes o columnas a la entrada de pasillos
- Paneles informativos existentes
- Esquinas visibles de salas

**Evitar:**
- ❌ Superficies rugosas o texturizadas
- ❌ Lugares con sombras o poca luz
- ❌ Áreas con mucho tráfico que puedan dañar el QR
- ❌ Superficies curvas o irregulares
- ❌ Lugares donde pueda recibir luz solar directa (se decolora)

### 3. Proceso de Instalación

1. **Limpiar:** Usa alcohol isopropílico para limpiar la superficie
2. **Secar:** Espera 2-3 minutos para que seque completamente
3. **Alinear:** Coloca el sticker de forma vertical y centrada
4. **Pegar:** Presiona desde el centro hacia los bordes para evitar burbujas
5. **Alisar:** Usa una tarjeta de crédito para eliminar burbujas de aire
6. **Probar:** Escanea con la app para verificar que funciona

### 4. Mapeo de Ubicaciones

Anota dónde instalaste cada QR:

| Código QR | Ubicación física | Fecha instalación | Estado |
|-----------|------------------|-------------------|--------|
| QR_P1_Entrada_1 | Puerta principal | DD/MM/YYYY | ✅ |
| ... | ... | ... | ... |

## 📱 Uso con la Aplicación

### Escanear un QR

1. Abre la app "Navegación UMAG"
2. Presiona el botón **📷 Escanear QR**
3. Apunta la cámara al código QR
4. Espera la detección automática
5. Tu ubicación actual se marcará en el mapa

### Navegar a un Destino

1. Después de escanear tu ubicación
2. Busca o selecciona tu destino en el mapa
3. La app calculará la ruta más corta
4. Sigue las indicaciones visuales en el mapa

## 🔧 Mantenimiento

### Inspección Regular (cada 3 meses)

- [ ] Verifica que los QRs estén limpios
- [ ] Comprueba que no haya daños físicos
- [ ] Prueba el escaneo con la aplicación
- [ ] Reemplaza los QRs dañados o ilegibles

### Limpieza

- Usa un paño suave ligeramente húmedo
- No uses productos químicos agresivos
- Seca con paño limpio sin frotar

### Reemplazo

Si un QR está dañado:
1. Regenera el QR específico con el script
2. Imprime el nuevo QR
3. Retira cuidadosamente el QR antiguo
4. Instala el nuevo siguiendo el proceso anterior

## 🛠️ Regenerar Códigos QR

### Todos los pisos

```bash
cd scripts
python generar_qrs.py
```

### Solo un piso específico

Modifica `generar_qrs.py` comentando los pisos que no necesites:

```python
configuracion_pisos = [
    (1, 'lib/data/grafo_piso1.json', 'qr_codes/piso1'),  # Solo este piso
    # (2, 'lib/data/grafo_piso2.json', 'qr_codes/piso2'),
    # (3, 'lib/data/grafo_piso3.json', 'qr_codes/piso3'),
    # (4, 'lib/data/grafo_piso4.json', 'qr_codes/piso4'),
]
```

### Instalar dependencias

```bash
pip install -r scripts/requirements.txt
```

## 📊 Estadísticas de Generación

- **Total de QRs:** 108
- **Piso 1:** 50 ubicaciones
- **Piso 2:** 24 ubicaciones
- **Piso 3:** 22 ubicaciones
- **Piso 4:** 12 ubicaciones

**Última generación:** 2025-12-15 02:03:42

## 🐛 Solución de Problemas

### El QR no escanea

**Posibles causas:**
1. **Iluminación insuficiente** → Usar la linterna del teléfono
2. **QR dañado** → Reemplazar el sticker
3. **Distancia incorrecta** → Acercar o alejar la cámara (15-30 cm ideal)
4. **Cámara desenfocada** → Limpiar el lente de la cámara

### El QR escanea pero da error

1. Verifica que el ID del nodo exista en el archivo JSON del grafo
2. Comprueba que el piso coincida con el piso actual en la app
3. Regenera el QR con el script actualizado

### QRs ilegibles después de impresión

1. Aumenta la resolución de impresión (mínimo 300 DPI)
2. Verifica que la impresora tenga suficiente tinta/tóner
3. Usa papel de mejor calidad
4. Ajusta el contraste al máximo

## 📞 Contacto y Soporte

**Sistema de Navegación UMAG**
- Facultad de Ingeniería
- Universidad de Magallanes

Para reportar problemas o solicitar nuevos QRs, contacta al equipo de desarrollo.

## 📝 Notas Técnicas

- Los QRs usan corrección de errores **nivel H** (30%)
- Cada QR puede tener hasta 30% de daño y seguir funcionando
- El formato es compatible con cualquier lector QR estándar
- Los datos están en formato UTF-8 para soportar caracteres especiales

---

**Versión:** 1.0  
**Última actualización:** Diciembre 2025  
**Script de generación:** `scripts/generar_qrs.py`
