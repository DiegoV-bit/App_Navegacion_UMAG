import os
import re

# Configuración de pisos
pisos = {
    1: "c:/Users/DiegoV-bit/OneDrive/Desktop/Repos github/App_Navegacion_UMAG/qr_codes/piso1",
    2: "c:/Users/DiegoV-bit/OneDrive/Desktop/Repos github/App_Navegacion_UMAG/qr_codes/piso2",
    3: "c:/Users/DiegoV-bit/OneDrive/Desktop/Repos github/App_Navegacion_UMAG/qr_codes/piso3",
    4: "c:/Users/DiegoV-bit/OneDrive/Desktop/Repos github/App_Navegacion_UMAG/qr_codes/piso4"
}

def extraer_nombre_ubicacion(nombre_archivo):
    """Extrae el nombre de la ubicación del nombre del archivo QR"""
    # Remover QR_P#_ y .png
    nombre = re.sub(r'^QR_P\d+_', '', nombre_archivo)
    nombre = re.sub(r'\.png$', '', nombre)
    # Reemplazar guiones bajos con espacios
    nombre = nombre.replace('_', ' ')
    return nombre

def crear_pagina_latex(ubicacion, numero_piso, ruta_qr):
    """Crea el código LaTeX para una página de afiche"""
    return f"""% ================== PÁGINA: {ubicacion} ==================
\\pagestyle{{empty}}
\\begin{{center}}
\\begin{{tabular}}{{ m{{4.5cm}} m{{6cm}} m{{4.5cm}} }}
\\centering
\\includegraphics[width=3.5cm]{{Logos/umag.png}}
&
\\centering
{{\\large \\textbf{{Facultad de Ingeniería}}}}
&
\\centering
\\includegraphics[width=3.5cm]{{Logos/dic.png}}
\\end{{tabular}}
\\end{{center}}
\\vspace{{0.5cm}}
\\begin{{center}}
\\colorbox{{blue!15}}{{\\parbox{{0.9\\textwidth}}{{
  \\centering
  \\vspace{{0.3cm}}
  {{\\Huge \\textbf{{{ubicacion}}}}}\\\\[0.2cm]
  {{\\LARGE Piso {numero_piso}}}
  \\vspace{{0.3cm}}
}}}}
\\end{{center}}
\\vspace{{0.6cm}}
\\begin{{center}}
{{\\LARGE \\textbf{{Sistema de Navegación Interna}}}}
\\end{{center}}
\\vspace{{0.4cm}}
\\begin{{center}}
\\begin{{tcolorbox}}[width=0.9\\textwidth, colback=gray!5, colframe=black!50, boxrule=0.5pt, arc=3mm]
\\vspace{{0.1cm}}
{{\\large \\textbf{{¿Cómo usar?}}}}
\\vspace{{0.2cm}}
\\begin{{enumerate}}[leftmargin=2cm, labelsep=0.5cm, itemsep=0.3cm]
  \\item[\\textbf{{1.}}] Abre la app \\textbf{{``Mi Facultad UMAG''}}
  \\item[\\textbf{{2.}}] Escanea el código QR de abajo
  \\item[\\textbf{{3.}}] Selecciona tu destino
  \\item[\\textbf{{4.}}] Sigue la ruta mostrada
\\end{{enumerate}}
\\vspace{{0.1cm}}
\\end{{tcolorbox}}
\\end{{center}}
\\vspace{{0.5cm}}
\\begin{{center}}
\\fbox{{\\includegraphics[width=7cm]{{{ruta_qr}}}}}
\\end{{center}}
\\vspace{{0.4cm}}
\\begin{{center}}
{{\\footnotesize
\\textit{{Aplicación de navegación interna - Universidad de Magallanes}}
}}
\\end{{center}}
"""

def crear_documento_piso(numero_piso, ruta_carpeta):
    """Crea el documento LaTeX completo para un piso"""
    # Obtener todos los archivos QR del piso
    archivos_qr = sorted([f for f in os.listdir(ruta_carpeta) if f.endswith('.png')])
    
    # Encabezado del documento
    documento = r"""\documentclass[a4paper,12pt]{article}

% ---------------- PAQUETES ----------------
\usepackage[spanish]{babel}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{graphicx}
\usepackage{geometry}
\usepackage{xcolor}
\usepackage{helvet}
\usepackage{array}
\usepackage{tcolorbox}
\usepackage{enumitem}

\renewcommand{\familydefault}{\sfdefault}

% ---------------- MÁRGENES ----------------
\geometry{
  top=1.5cm,
  bottom=1.5cm,
  left=1.8cm,
  right=1.8cm
}

\begin{document}

"""
    
    # Agregar cada página
    for i, archivo in enumerate(archivos_qr):
        ubicacion = extraer_nombre_ubicacion(archivo)
        ruta_qr = f"../qr_codes/piso{numero_piso}/{archivo}"
        
        documento += crear_pagina_latex(ubicacion, numero_piso, ruta_qr)
        
        # Agregar \newpage excepto en la última página
        if i < len(archivos_qr) - 1:
            documento += "\\newpage\n\n"
    
    # Cerrar documento
    documento += "\n\\end{document}\n"
    
    return documento

# Generar documentos para cada piso
for numero_piso, ruta_carpeta in pisos.items():
    documento = crear_documento_piso(numero_piso, ruta_carpeta)
    
    # Guardar el documento
    nombre_archivo = f"Afiches_Piso{numero_piso}.tex"
    ruta_salida = f"c:/Users/DiegoV-bit/OneDrive/Desktop/Repos github/App_Navegacion_UMAG/Formato_codigos_QR/{nombre_archivo}"
    
    with open(ruta_salida, 'w', encoding='utf-8') as f:
        f.write(documento)
    
    print(f"✓ Generado: {nombre_archivo} con {len(os.listdir(ruta_carpeta))} códigos QR")

print("\n¡Todos los documentos LaTeX han sido generados!")
print("\nPara compilar a PDF, ejecuta:")
for i in range(1, 5):
    print(f"  pdflatex Afiches_Piso{i}.tex")
