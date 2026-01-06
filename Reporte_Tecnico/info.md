# Template DICUMAG · Plantilla LaTeX para informes de práctica

Este directorio aporta un punto de partida ligero para redactar informes académicos o técnicos y está listo para compartirse dentro del departamento. El archivo principal (`main.tex`) usa paquetes básicos (`geometry`, `inputenc`, `babel` en español, `graphicx`, `xcolor`, `hyperref`, `fancyhdr`) y deja preparadas macros que puedes personalizar rápidamente.

## Archivos disponibles
- `main.tex`: documento base con placeholders para completar con los datos del informe. Incluye:
  - Preambulo compacto con los paquetes mencionados y la ruta `\graphicspath` apuntando a `./`, `./logo/` y `./image/`, de modo que las imágenes se encuentren utilizando rutas relativas sencillas.
  - Macros (`\institucion`, `\facultad`, `\programa`, `\curso`, `\docente`, `\estudiante`, `\titulo`, `\fechaentrega`) cargadas con valores genéricos que puedes reemplazar; los campos de título y fecha se muestran en itálica para recordar que debes modificarlos.
  - Encabezados y pies configurados mediante `fancyhdr` con la institución y el curso.
  - Portada con los logos `umag.png` y `dic.png`, más una imagen central (`placeholder.png`).
  - Saltos de página y `\tableofcontents` ya ubicados para generar el índice automáticamente tras una segunda compilación.
  - Secciones iniciales listas para completar (Resumen, Objetivos, Metodología, Resultados, Conclusiones, Próximos Pasos), una sección para detallar el uso de apoyos autorizados y un ejemplo de entorno `figure` que referencia la imagen de muestra.
  - Un bloque de bibliografía ejemplar con referencias del área de Computación e Informática.
- `logo/umag.png`: logotipo de la Universidad de Magallanes utilizado en la portada.
- `logo/dic.png`: logotipo del Departamento de Ingeniería en Computación que acompaña al anterior.
- `image/placeholder.png`: imagen genérica para pruebas o cuando aún no se dispone del diagrama definitivo.

## Cómo utilizar la plantilla
1. Duplica `main.tex` y renómbralo según la práctica (por ejemplo `practica2.tex`) o trabaja directamente sobre una copia.
2. Ajusta el bloque de macros al comienzo del archivo con los datos reales. Los valores en itálica señalan campos por completar.
3. Actualiza el contenido de las secciones predefinidas. La sección “Declaración de Uso de Apoyo” está pensada para transparentar el empleo de IA, OCR u otras herramientas autorizadas; ajústala según las políticas del curso. Si aún no cuentas con imágenes definitivas, deja `image/placeholder.png` tanto en la portada como en el ejemplo de figura y cámbialas más adelante.
4. Completa o sustituye las entradas de la bibliografía de ejemplo (`Referencias`) con las fuentes que utilices en tu informe.
5. Compila desde PowerShell ejecutando `pdflatex` dos veces para que el índice (`main.toc`) y las referencias queden sincronizados:

  ```powershell
  pdflatex practica2.tex
  pdflatex practica2.tex
  ```

6. Si deseas usar otros logos o imágenes de portada, reemplaza los archivos en `logo/` e `image/` manteniendo los mismos nombres (o ajusta la ruta en `main.tex`).

## Créditos

Plantilla elaborada por Emmanuel Velásquez ([CheeseChariot](https://github.com/CheeseChariot)).
