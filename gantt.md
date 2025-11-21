``` mermaid
gantt
    title Planificación del Proyecto – Gantt
    dateFormat  DD-MM-YYYY
    axisFormat  %d-%m

    section Digitalización del plano de la facultad de ingeniería
    Digitalización general                       :done,      des0,  11-09-2025, 10d
    Primer piso                                   :des1,      15-09-2025, 16-09-2025
    Segundo piso                                  :des2,      17-09-2025, 18-09-2025
    Tercer piso                                   :des3,      19-09-2025, 20-09-2025
    Cuarto piso                                   :des4,      20-09-2025, 21-09-2025
    Investigación sobre creación de apps móviles  :des5,      15-09-2025, 28-09-2025

    section Desarrollo de la aplicación web
    Preparación del entorno y repositorio Github  :dev0,      29-09-2025, 10-10-2025
    Estructura de carpetas                        :dev1,      1d
    Creación interfaz gráfica                     :dev2,      26-10-2025, 26-10-2025
    Creación navegación entre pantallas           :dev3,      5d
    Sistema de zoom                               :dev4,      2d
    Controles flotantes zoom                       :dev5,      2d
    Sistema de coordenadas y transformaciones     :dev6,      4d

    Creación de clases y métodos para los grafos  :dev7,      01-11-2025, 01-11-2025
    Implementación para cargar grafos             :dev8,      2d
    Visualización de nodos en el mapa             :dev9,      2d
    Sistema de íconos diferenciados               :dev10,     1d
    Información de cada nodo visual               :dev11,     1d
    Creación de modo debug                        :dev12,     5d
    Activar y desactivar modo debug               :dev13,     2d
    Captura coordenadas mediante toque            :dev14,     2d
    Sistema de marcadores debug                   :dev15,     2d
    Carga de datos desde JSON                     :dev16,     2d

    section Mapas y rutas
    Armado de los grafos                          :dev17, Bruno, 03-11-2025, 11-11-2025
    Algoritmo de rutas                            :dev18, Bruno, 13-10-2025, 26-10-2025
    Integración de mapas                          :dev19, Diego, 13-10-2025, 23-10-2025
    Visualización de las rutas                    :dev20, Bruno, 13-10-2025, 26-10-2025
    Funcionalidades extra (QR, búsqueda, selector):dev21, Diego, 27-10-2025, 09-11-2025

    section Integración final
    Escalado a todo el edificio                   :dev22, 03-11-2025, 23-11-2025
    Pruebas finales                               :dev23, 24-11-2025, 07-12-2025
```
