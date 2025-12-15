#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script Auxiliar - Regenerar QRs de un Piso Específico
Sistema de Navegación Interior - UMAG

Uso:
    python generar_qr_piso.py [numero_piso]
    
Ejemplos:
    python generar_qr_piso.py 1        # Regenera solo el piso 1
    python generar_qr_piso.py 2        # Regenera solo el piso 2
"""

import sys
import os
from pathlib import Path

# Configurar encoding UTF-8 para Windows
if sys.platform.startswith('win'):
    os.system('chcp 65001 >nul 2>&1')

# Importar funciones del script principal
sys.path.insert(0, str(Path(__file__).parent))
from generar_qrs import generar_qrs_desde_grafo

def main():
    if len(sys.argv) < 2:
        print("❌ Error: Debes especificar el número de piso")
        print("\n📖 Uso:")
        print("   python generar_qr_piso.py [1|2|3|4]")
        print("\n📝 Ejemplos:")
        print("   python generar_qr_piso.py 1    # Regenera piso 1")
        print("   python generar_qr_piso.py 3    # Regenera piso 3")
        return 1
    
    try:
        piso = int(sys.argv[1])
        if piso not in [1, 2, 3, 4]:
            print(f"❌ Error: Piso '{piso}' no válido. Debe ser 1, 2, 3 o 4")
            return 1
    except ValueError:
        print(f"❌ Error: '{sys.argv[1]}' no es un número válido")
        return 1
    
    # Configuración de rutas
    directorio_base = Path(__file__).parent.parent
    ruta_grafo = directorio_base / f'lib/data/grafo_piso{piso}.json'
    carpeta_salida = directorio_base / f'qr_codes/piso{piso}'
    
    # Verificar que existe el archivo
    if not ruta_grafo.exists():
        print(f"❌ Error: No se encontró el archivo {ruta_grafo}")
        return 1
    
    print("\n" + "=" * 70)
    print(f"🗺️  REGENERAR QRs - PISO {piso}")
    print("=" * 70)
    
    # Generar QRs
    cantidad = generar_qrs_desde_grafo(
        str(ruta_grafo),
        str(carpeta_salida),
        piso
    )
    
    print("\n" + "=" * 70)
    if cantidad > 0:
        print(f"✅ {cantidad} códigos QR regenerados correctamente")
        print(f"📂 Ubicación: {carpeta_salida}")
    else:
        print("⚠️  No se generaron códigos QR")
    print("=" * 70 + "\n")
    
    return 0 if cantidad > 0 else 1

if __name__ == "__main__":
    sys.exit(main())
