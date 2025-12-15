#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de Códigos QR para Sistema de Navegación Interior
Facultad de Ingeniería - Universidad de Magallanes

Este script genera códigos QR para todos los nodos definidos en los archivos
JSON de cada piso, facilitando la navegación interior mediante escaneo QR.

Autor: Sistema de Navegación UMAG
Fecha: Diciembre 2025
"""

import json
import qrcode
from pathlib import Path
from datetime import datetime
import sys
import os

# Configurar encoding UTF-8 para Windows
if sys.platform.startswith('win'):
    os.system('chcp 65001 >nul 2>&1')

# Configuración de generación de QR
QR_CONFIG = {
    'version': 1,  # Versión 1 = QR más pequeño posible
    'error_correction': qrcode.constants.ERROR_CORRECT_H,  # Nivel H = 30% de corrección
    'box_size': 10,  # Tamaño de cada caja en píxeles
    'border': 4,  # Borde mínimo requerido
}

# Configuración de imagen
IMAGE_CONFIG = {
    'fill_color': 'black',
    'back_color': 'white',
}

def leer_grafo_json(ruta_json):
    """
    Lee y valida un archivo JSON de grafo.
    
    Args:
        ruta_json (str): Ruta al archivo JSON
        
    Returns:
        dict: Datos del grafo o None si hay error
    """
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
    except Exception as e:
        print(f"❌ Error inesperado al leer {ruta_json}: {e}")
        return None

def extraer_numero_piso(nodo_id):
    """
    Extrae el número de piso del ID del nodo.
    
    Args:
        nodo_id (str): ID del nodo (ej: "P1_Entrada_1")
        
    Returns:
        int: Número de piso o 1 por defecto
    """
    try:
        # Formato esperado: "P{numero}_{resto}"
        if '_' in nodo_id and nodo_id.startswith('P'):
            piso_str = nodo_id.split('_')[0].replace('P', '')
            return int(piso_str)
    except (ValueError, IndexError):
        pass
    
    return 1  # Piso por defecto

def crear_datos_qr(nodo, piso_default=1):
    """
    Crea los datos del QR en el formato esperado por la aplicación.
    
    Args:
        nodo (dict): Datos del nodo
        piso_default (int): Número de piso por defecto
        
    Returns:
        str: JSON string con los datos del QR
    """
    nodo_id = nodo.get('id', '')
    piso = extraer_numero_piso(nodo_id) if nodo_id else piso_default
    
    # Formato compatible con codigo_qr.dart
    qr_data = {
        "type": "nodo",
        "id": nodo_id,
        "piso": piso,
        "x": nodo.get('x'),
        "y": nodo.get('y')
    }
    
    return json.dumps(qr_data, ensure_ascii=False)

def generar_qr_imagen(datos_qr, ruta_salida):
    """
    Genera una imagen de código QR.
    
    Args:
        datos_qr (str): Datos a codificar en el QR
        ruta_salida (str): Ruta donde guardar la imagen
        
    Returns:
        bool: True si se generó correctamente
    """
    try:
        # Crear objeto QR
        qr = qrcode.QRCode(**QR_CONFIG)
        qr.add_data(datos_qr)
        qr.make(fit=True)
        
        # Generar imagen
        img = qr.make_image(**IMAGE_CONFIG)
        
        # Guardar imagen
        img.save(ruta_salida)
        return True
        
    except Exception as e:
        print(f"❌ Error generando QR: {e}")
        return False

def generar_qrs_desde_grafo(ruta_json, carpeta_salida, numero_piso=None):
    """
    Genera códigos QR para todos los nodos de un grafo.
    
    Args:
        ruta_json (str): Ruta al archivo JSON del grafo
        carpeta_salida (str): Carpeta donde guardar los QRs
        numero_piso (int): Número de piso (se extrae del nombre si es None)
        
    Returns:
        int: Cantidad de QRs generados exitosamente
    """
    # Leer grafo
    grafo = leer_grafo_json(ruta_json)
    if not grafo:
        return 0
    
    nodos = grafo.get('nodos', [])
    if not nodos:
        print(f"⚠️  No hay nodos en el archivo: {ruta_json}")
        return 0
    
    # Extraer número de piso del nombre del archivo si no se especificó
    if numero_piso is None:
        try:
            # Extraer de "grafo_pisoN.json"
            nombre_archivo = Path(ruta_json).stem
            numero_piso = int(nombre_archivo.split('piso')[1])
        except (ValueError, IndexError):
            numero_piso = 1
    
    # Crear carpeta de salida
    Path(carpeta_salida).mkdir(parents=True, exist_ok=True)
    
    print(f"\n📍 Generando QRs para {len(nodos)} nodos del piso {numero_piso}...")
    print(f"📂 Guardando en: {carpeta_salida}")
    print("─" * 70)
    
    exitosos = 0
    errores = 0
    
    for i, nodo in enumerate(nodos, 1):
        nodo_id = nodo.get('id', f'nodo_{i}')
        
        # Crear datos del QR
        datos_qr = crear_datos_qr(nodo, numero_piso)
        
        # Generar nombre de archivo
        nombre_archivo = f"QR_{nodo_id}.png"
        ruta_salida = Path(carpeta_salida) / nombre_archivo
        
        # Generar QR
        if generar_qr_imagen(datos_qr, ruta_salida):
            exitosos += 1
            # Mostrar progreso cada 10 nodos o en el último
            if i % 10 == 0 or i == len(nodos):
                print(f"  [{i:3d}/{len(nodos)}] ✓ {nombre_archivo}")
        else:
            errores += 1
            print(f"  [{i:3d}/{len(nodos)}] ✗ Error en {nombre_archivo}")
    
    print("─" * 70)
    print(f"✅ Completado: {exitosos} QRs generados correctamente")
    if errores > 0:
        print(f"⚠️  {errores} errores durante la generación")
    
    return exitosos

def generar_qrs_todos_los_pisos(directorio_base='.'):
    """
    Genera QRs para todos los pisos disponibles.
    
    Args:
        directorio_base (str): Directorio raíz del proyecto
        
    Returns:
        dict: Estadísticas de generación por piso
    """
    # Definir rutas de grafos y salidas
    configuracion_pisos = [
        (1, 'lib/data/grafo_piso1.json', 'qr_codes/piso1'),
        (2, 'lib/data/grafo_piso2.json', 'qr_codes/piso2'),
        (3, 'lib/data/grafo_piso3.json', 'qr_codes/piso3'),
        (4, 'lib/data/grafo_piso4.json', 'qr_codes/piso4'),
    ]
    
    print("\n" + "=" * 70)
    print("🗺️  GENERADOR DE CÓDIGOS QR - NAVEGACIÓN UMAG")
    print("=" * 70)
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📂 Directorio base: {Path(directorio_base).absolute()}")
    print("=" * 70)
    
    estadisticas = {}
    total_generados = 0
    
    for numero_piso, ruta_grafo, carpeta_salida in configuracion_pisos:
        # Construir rutas absolutas
        ruta_grafo_completa = Path(directorio_base) / ruta_grafo
        carpeta_salida_completa = Path(directorio_base) / carpeta_salida
        
        if not ruta_grafo_completa.exists():
            print(f"\n⚠️  Archivo no encontrado: {ruta_grafo_completa}")
            estadisticas[numero_piso] = 0
            continue
        
        # Generar QRs para este piso
        cantidad = generar_qrs_desde_grafo(
            str(ruta_grafo_completa),
            str(carpeta_salida_completa),
            numero_piso
        )
        
        estadisticas[numero_piso] = cantidad
        total_generados += cantidad
    
    # Resumen final
    print("\n" + "=" * 70)
    print("📊 RESUMEN DE GENERACIÓN")
    print("=" * 70)
    
    for piso, cantidad in sorted(estadisticas.items()):
        if cantidad > 0:
            print(f"  Piso {piso}: {cantidad:3d} QRs generados")
        else:
            print(f"  Piso {piso}: ⚠️  Sin QRs generados")
    
    print("─" * 70)
    print(f"  TOTAL:  {total_generados:3d} códigos QR generados")
    print("=" * 70)
    
    if total_generados > 0:
        print("\n✅ Proceso completado exitosamente")
        print("\n📌 PRÓXIMOS PASOS:")
        print("   1. Revisa los QRs generados en la carpeta 'qr_codes/'")
        print("   2. Imprime los QRs en stickers de 5x5 cm")
        print("   3. Coloca los QRs a 1.5m de altura en cada ubicación")
        print("   4. Prueba el escaneo con la aplicación móvil")
        print("\n💡 TIP: Los QRs tienen corrección de errores nivel H (30%)")
        print("   Esto permite que funcionen incluso con daños menores.")
    else:
        print("\n⚠️  No se generaron códigos QR")
        print("   Verifica que los archivos JSON existan en 'lib/data/'")
    
    print("\n")
    return estadisticas

def generar_archivo_info():
    """Genera un archivo README con información sobre los QRs generados."""
    readme_content = """# Códigos QR - Sistema de Navegación UMAG

## 📋 Información General

Este directorio contiene los códigos QR generados para el sistema de navegación
interior de la Facultad de Ingeniería de la Universidad de Magallanes.

## 📁 Estructura

```
qr_codes/
├── piso1/          # QRs del primer piso
├── piso2/          # QRs del segundo piso
├── piso3/          # QRs del tercer piso
└── piso4/          # QRs del cuarto piso
```

## 🔍 Formato de Datos

Cada código QR contiene información en formato JSON:

```json
{
  "type": "nodo",
  "id": "P1_Entrada_1",
  "piso": 1,
  "x": 100,
  "y": 200
}
```

## 📏 Especificaciones de Impresión

- **Tamaño recomendado:** 5x5 cm
- **Tamaño mínimo:** 3x3 cm
- **Material:** Stickers vinilo plastificado (resistente al agua)
- **Colores:** Blanco y negro únicamente
- **Corrección de errores:** Nivel H (30% de corrección)

## 📍 Instrucciones de Instalación

1. **Impresión:**
   - Usa una impresora láser o de inyección de tinta de alta calidad
   - Imprime en papel adhesivo vinilo
   - Asegúrate de que el contraste sea alto (negro puro sobre blanco puro)

2. **Colocación:**
   - Altura estándar: 1.5 metros desde el suelo
   - Superficie: Limpia, seca y plana
   - Ubicación: Visible y accesible
   - Evita: Esquinas, bordes, superficies rugosas

3. **Mantenimiento:**
   - Limpia periódicamente con paño húmedo
   - Reemplaza si el QR está dañado o ilegible
   - Verifica el escaneo con la app cada 3 meses

## 📱 Uso con la Aplicación

1. Abre la aplicación "Navegación UMAG"
2. Selecciona el piso actual
3. Presiona el botón de escaneo QR
4. Apunta la cámara al código QR
5. El sistema detectará tu ubicación automáticamente
6. Selecciona tu destino para obtener la ruta

## 🛠️ Regenerar QRs

Si necesitas regenerar los códigos QR:

```bash
cd scripts
python generar_qrs.py
```

## 📧 Soporte

Para reportar problemas con los códigos QR o solicitar nuevos:
- Sistema de Navegación UMAG
- Facultad de Ingeniería - Universidad de Magallanes

---

**Fecha de generación:** {fecha}
**Versión:** 1.0
"""
    
    try:
        readme_path = Path('qr_codes/README.md')
        readme_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content.format(
                fecha=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            ))
        
        print(f"📄 Archivo de información creado: {readme_path}")
        return True
    except Exception as e:
        print(f"⚠️  Error creando archivo README: {e}")
        return False

def main():
    """Función principal del script."""
    try:
        # Obtener directorio base del proyecto
        directorio_base = Path(__file__).parent.parent
        
        # Generar QRs para todos los pisos
        estadisticas = generar_qrs_todos_los_pisos(str(directorio_base))
        
        # Generar archivo de información
        if sum(estadisticas.values()) > 0:
            generar_archivo_info()
        
        return 0 if sum(estadisticas.values()) > 0 else 1
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Proceso interrumpido por el usuario")
        return 1
    except Exception as e:
        print(f"\n❌ Error inesperado: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
