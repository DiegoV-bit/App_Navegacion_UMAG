# Creación de la interfaz gráfica

La interfaz gráfica de la aplicación se desarrolló usando Flutter como framework principal, aprovechando su capacidad de crear interfaces nativas y fluidas con un único código base. El diseño de la app se enfocó en la simplicidad y usabilidad, considerando que los usuarios principales serían estudiantes nuevos y visitantes que necesitan orientarse rápidamente dentro de la facultad.

## Estructura de la aplicación

La aplicación se estructuró en dos pantallas principales que permiten una navegación intuitiva:

### Pantalla de inicio (PantallaInicio)

Esta pantalla funciona como punto de entrada de la aplicación y presenta las siguientes características:

- **Diseño visual atractivo**: Se implementó un gradiente de color que va desde un azul claro en la parte superior hasta blanco en la parte inferior, creando una interfaz agradable visualmente y manteniendo la identidad institucional mediante el uso del color azul.

- **Encabezado informativo**: En la parte superior se muestra un ícono de ubicación de gran tamaño junto con el título "Navegación Interna" y un subtítulo descriptivo, lo que permite al usuario identificar inmediatamente el propósito de la aplicación.

- **Sistema de tarjetas por piso**: La funcionalidad principal se presenta mediante cuatro tarjetas interactivas, una por cada piso de la facultad. Cada tarjeta incluye:
  - Un ícono distintivo que representa el tipo de espacios del piso (ciencia para laboratorios, escuela para aulas, libro para salas de estudio, y edificio para administración)
  - Un título claro con el nombre del piso
  - Una descripción breve de los espacios que contiene
  - Un indicador visual de navegación (flecha)
  - Códigos de color diferenciados (verde, naranja, morado y rojo) para facilitar la identificación rápida

Esta organización permite que el usuario seleccione rápidamente el piso que desea explorar con solo tocar la tarjeta correspondiente.

### Pantalla de mapa (PantallaMapa)

Una vez seleccionado un piso, el usuario es dirigido a la pantalla de mapa, que constituye el componente central de la aplicación. Esta pantalla implementa las siguientes funcionalidades:

- **Visualización de mapas SVG**: Se integró el paquete `flutter_svg` para cargar y mostrar los mapas arquitectónicos en formato SVG. La aplicación determina dinámicamente qué archivo SVG cargar según el piso seleccionado, utilizando las rutas:
  - Primer piso: `Mapas/Primer piso labs_fac_ing simple.svg`
  - Segundo piso: `Mapas/Segundo piso fac ing simple.svg`
  - Tercer piso: `Mapas/Tercer piso fac_ing simple.svg`
  - Cuarto piso: `Mapas/Cuarto piso fac_ing simple.svg`

- **Navegación interactiva**: Se implementó el widget `InteractiveViewer` de Flutter, que proporciona:
  - Desplazamiento táctil (pan) para explorar diferentes áreas del mapa
  - Zoom mediante gestos de pellizco en pantallas táctiles
  - Límites de escala configurables (mínimo 0.3x, máximo 5.0x) para mantener la visualización en rangos útiles

- **Controles de zoom**: Se añadieron tres botones flotantes en la parte inferior derecha que permiten:
  - Acercar el mapa (zoom in) aumentando la escala en un 20%
  - Alejar el mapa (zoom out) reduciendo la escala en un 20%
  - Reiniciar la vista al estado inicial, útil cuando el usuario pierde orientación

- **Gestión de estados de carga**: La aplicación implementa un sistema robusto para manejar diferentes estados:
  - Estado de carga: Muestra un indicador circular de progreso con el texto "Cargando mapa..."
  - Estado de error: En caso de que el archivo SVG no se encuentre o no pueda cargarse, se muestra un mensaje de error detallado con el ícono de advertencia, el nombre del archivo que se intentó cargar y la descripción del error específico

- **Barra informativa**: Se incluyó una barra azul claro debajo del encabezado que muestra el nombre del piso actual y proporciona una indicación visual de que se puede hacer zoom con gestos de pellizco.

## Implementación técnica

### Widget principal y navegación

La aplicación utiliza `MaterialApp` como widget raíz, configurando el tema principal con Material Design 3 (`useMaterial3: true`) para aprovechar los componentes de diseño más modernos de Flutter. El sistema de navegación se basa en `Navigator.push()`, que permite transiciones fluidas entre la pantalla de inicio y las pantallas de mapas.

### Gestión de transformaciones

Para controlar el zoom y desplazamiento del mapa, se implementó un `TransformationController` que mantiene una matriz de transformación 4x4 (`Matrix4`). Esta matriz permite aplicar operaciones de escala y traslación al mapa de forma eficiente, proporcionando una experiencia de usuario fluida incluso con mapas de gran tamaño.

Las operaciones de zoom se realizan clonando la matriz actual, aplicando la escala deseada y actualizando el controlador, lo que garantiza que las transformaciones se realicen de forma acumulativa y coherente.

### Carga asíncrona de recursos

La aplicación implementa un patrón de carga asíncrona mediante `FutureBuilder`, que permite mostrar indicadores de progreso mientras se cargan los archivos SVG. Este enfoque mejora significativamente la experiencia del usuario, especialmente en dispositivos con menor rendimiento o cuando los archivos de mapa son de gran tamaño.

## Consideraciones de diseño

Durante el desarrollo de la interfaz se tomaron varias decisiones importantes:

1. **Material Design**: Se adoptó el sistema de diseño Material de Google para garantizar consistencia visual y aprovechar componentes probados en cuanto a usabilidad.

2. **Retroalimentación visual**: Todos los elementos interactivos proporcionan retroalimentación visual mediante efectos de elevación (`elevation`) en las tarjetas y efectos de onda (`InkWell`) al tocar.

3. **Accesibilidad**: Se implementaron tooltips en todos los botones de acción para ayudar a los usuarios a comprender la funcionalidad de cada control.

4. **Manejo de errores**: Se diseñó una pantalla de error informativa que no solo indica que algo salió mal, sino que proporciona detalles técnicos útiles para diagnosticar el problema.

Esta implementación inicial de la interfaz gráfica estableció las bases para el desarrollo posterior de funcionalidades más avanzadas, como el sistema de navegación basado en grafos y el cálculo de rutas óptimas entre diferentes puntos de la facultad.