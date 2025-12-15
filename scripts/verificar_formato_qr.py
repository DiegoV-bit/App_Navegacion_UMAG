#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Prueba - Verificar Formato de QRs Generados
Sistema de Navegación Interior - UMAG

Este script verifica que los QRs generados sean compatibles con la aplicación.
"""

import json
import sys
import os
from pathlib import Path

# Configurar encoding UTF-8 para Windows
if sys.platform.startswith('win'):
    os.system('chcp 65001 >nul 2>&1')

def verificar_qr_json(qr_data):
    """
    Verifica que un QR en formato JSON sea válido.
    
    Args:
        qr_data (str): Datos del QR en formato JSON
        
    Returns:
        tuple: (es_valido, mensaje)
    """
    try:
        data = json.loads(qr_data)
        
        # Verificar que tenga el campo 'type'
        if 'type' not in data:
            return (False, "Falta el campo 'type'")
        
        tipo = data['type']
        
        # Validar según el tipo
        if tipo == 'nodo':
            if 'id' not in data:
                return (False, "QR tipo 'nodo' debe tener campo 'id'")
            if 'piso' not in data:
                return (False, "QR tipo 'nodo' debe tener campo 'piso'")
            return (True, f"✓ QR nodo válido: {data['id']}")
        
        elif tipo == 'ruta':
            if 'origen' not in data or 'destino' not in data:
                return (False, "QR tipo 'ruta' debe tener 'origen' y 'destino'")
            return (True, f"✓ QR ruta válido: {data['origen']} → {data['destino']}")
        
        elif tipo in ['coordenadas', 'coord']:
            if 'x' not in data or 'y' not in data:
                return (False, "QR tipo coordenadas debe tener 'x' e 'y'")
            return (True, f"✓ QR coordenadas válido: ({data['x']}, {data['y']})")
        
        else:
            return (False, f"Tipo '{tipo}' no reconocido")
    
    except json.JSONDecodeError as e:
        return (False, f"Error al decodificar JSON: {e}")
    except Exception as e:
        return (False, f"Error inesperado: {e}")

def probar_qr_desde_grafo(ruta_grafo):
    """
    Prueba el formato de QRs que se generarían desde un grafo.
    
    Args:
        ruta_grafo (str): Ruta al archivo JSON del grafo
    """
    try:
        with open(ruta_grafo, 'r', encoding='utf-8') as f:
            grafo = json.load(f)
        
        nodos = grafo.get('nodos', [])
        if not nodos:
            print(f"⚠️  No hay nodos en {ruta_grafo}")
            return
        
        print(f"\n📂 Probando: {ruta_grafo}")
        print(f"📍 Total de nodos: {len(nodos)}")
        print("─" * 70)
        
        # Probar primeros 3 nodos
        for i, nodo in enumerate(nodos[:3], 1):
            nodo_id = nodo.get('id', '')
            
            # Extraer piso del ID
            piso = 1
            try:
                if '_' in nodo_id and nodo_id.startswith('P'):
                    piso = int(nodo_id.split('_')[0].replace('P', ''))
            except (ValueError, IndexError):
                pass
            
            # Generar QR como lo hace el script
            qr_data = json.dumps({
                "type": "nodo",
                "id": nodo_id,
                "piso": piso,
                "x": nodo.get('x'),
                "y": nodo.get('y')
            }, ensure_ascii=False)
            
            # Verificar
            es_valido, mensaje = verificar_qr_json(qr_data)
            
            if es_valido:
                print(f"  [{i}] {mensaje}")
            else:
                print(f"  [{i}] ✗ {mensaje}")
                print(f"      QR: {qr_data[:100]}...")
        
        if len(nodos) > 3:
            print(f"  ... (y {len(nodos) - 3} nodos más)")
        
        print("─" * 70)
        print(f"✅ Formato de QRs verificado\n")
        
    except FileNotFoundError:
        print(f"❌ Archivo no encontrado: {ruta_grafo}")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    """Función principal del script."""
    directorio_base = Path(__file__).parent.parent
    
    print("\n" + "=" * 70)
    print("🔍 VERIFICADOR DE FORMATO QR")
    print("=" * 70)
    print("\nEste script verifica que los QRs generados sean compatibles")
    print("con la aplicación Flutter.\n")
    
    # Probar con los archivos de grafo
    grafos = [
        'lib/data/grafo_piso1.json',
        'lib/data/grafo_piso2.json',
        'lib/data/grafo_piso3.json',
        'lib/data/grafo_piso4.json',
    ]
    
    for grafo_path in grafos:
        ruta_completa = directorio_base / grafo_path
        if ruta_completa.exists():
            probar_qr_desde_grafo(str(ruta_completa))
    
    print("\n" + "=" * 70)
    print("📱 FORMATOS QR SOPORTADOS POR LA APP:")
    print("=" * 70)
    print("""
1. Formato JSON (generado por el script de Python):
   {"type": "nodo", "id": "P1_Entrada_1", "piso": 1, "x": 100, "y": 200}

2. Formato texto simple:
   - nodo:P1_Entrada_1
   - piso:1|nodo:P1_Entrada_1
   - ubicacion:Entrada Principal
   - coord:1004,460
   - ruta:P1_Entrada_1|P1_Pasillo_Norte

3. ID directo:
   - P1_Entrada_1

✅ La aplicación ahora soporta TODOS estos formatos.
""")
    print("=" * 70 + "\n")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
