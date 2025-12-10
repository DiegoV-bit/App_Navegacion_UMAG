# Informe: Algoritmo A* (A estrella)

## 1. ¿Qué es el algoritmo A*?

El algoritmo **A\*** es un método de búsqueda heurística utilizado para encontrar la ruta más corta entre dos puntos dentro de un grafo.  
Se basa en combinar dos valores:

- **g(n):** el costo real acumulado desde el inicio.
- **h(n):** una heurística que estima el costo faltante hacia el objetivo.

De este modo, evalúa cada nodo mediante:

```
f(n) = g(n) + h(n)
```

Esta combinación permite que A* sea eficiente y encuentre rutas óptimas siempre que la heurística sea admisible (no sobreestima).

---

## 2. ¿Cómo se implementó el algoritmo A*?

La implementación se realizó en Dart, integrándose con la clase `Grafo`, que modela los nodos (con sus coordenadas) y la adyacencia entre ellos.  
Los elementos esenciales de la implementación fueron:

### ✓ 2.1. Estructura general

Se creó la clase `AStar`, que funciona de dos modos:
- Como **instancia**, recibiendo un objeto `Grafo`.
- Como **API estática**, manteniendo compatibilidad con versiones previas.

```dart
class AStar {
  final Grafo grafo;
  AStar(this.grafo);

  List<String> calcular({required String origen, required String destino}) {
    return AStar.calcularRuta(grafo: grafo, origen: origen, destino: destino);
  }
}
```

### ✓ 2.2. Mapa de adyacencias

Se genera un mapa a partir del grafo:

```dart
final mapa = grafo.generarMapaAdyacencia();
```

Cada nodo queda asociado a otros nodos con los costos de distancia correspondientes.

### ✓ 2.3. Tablas internas del algoritmo

Se inicializan:

- `gScore`: costo acumulado.
- `fScore`: costo estimado total.
- `prev`: predecesores para reconstrucción de ruta.

Todos comienzan como infinito excepto el nodo inicial.

### ✓ 2.4. Proceso principal

El algoritmo itera sobre un conjunto de nodos abiertos:

1. Selecciona el nodo con menor `fScore`.
2. Si es el destino → reconstruye la ruta y finaliza.
3. Si no, revisa cada vecino:
   - Calcula un costo tentativo.
   - Si es menor al conocido, actualiza valores y agrega el vecino al conjunto abierto.

### ✓ 2.5. Heurística aplicada

La heurística utilizada es **distancia euclidiana** basada en coordenadas `(x, y)` de los nodos:

```
h = sqrt( (x1 - x2)² + (y1 - y2)² )
```

Esto es adecuado para navegación en mapas 2D como los planos de la facultad.

### ✓ 2.6. Reconstrucción de la ruta

Cuando se llega al destino, se reconstruye recorriendo el mapa `prev` desde el objetivo hacia el origen.

---

## 3. ¿Cómo se utiliza dentro de la aplicación?

El algoritmo se integró con la **interfaz gráfica** desarrollada en Flutter, particularmente en la pantalla del mapa:

1. El usuario selecciona un piso.
2. Se carga el mapa SVG correspondiente.
3. El usuario elige un punto de inicio y destino en el plano.
4. La aplicación crea una instancia de `AStar` pasando el grafo del piso.
5. Se ejecuta:

```dart
var aStar = AStar(grafo);
var ruta = aStar.calcular(origen: "A", destino: "B");
```

6. La ruta resultante es una lista ordenada de IDs de nodos, que se usa para dibujar el camino directamente sobre el mapa.

Este proceso permite navegación precisa entre salas, laboratorios y pasillos.

---

## 4. Relación con la interfaz gráfica

El archivo **Creacion_interfaz_grafica.md** describe la estructura que permite visualizar los mapas y manipularlos mediante zoom y desplazamiento.  
A* interactúa con esta interfaz de las siguientes maneras:

- Usa los nodos y sus coordenadas, que corresponden a puntos del SVG.
- La ruta devuelta se dibuja sobre el mapa para guiar al usuario.
- Aprovecha el sistema de carga asíncrona del mapa para evitar bloqueos.

En conjunto, la interfaz ofrece el entorno visual y A* proporciona la lógica de navegación.

---

## 5. Conclusión

La integración del algoritmo A* con la interfaz gráfica permite una experiencia de navegación interna eficiente y clara.  
El algoritmo determina rutas óptimas usando distancias reales y una heurística adecuada, mientras Flutter ofrece la visualización interactiva del plano de la facultad.

Este diseño modular facilita extender la aplicación a nuevos pisos o edificios simplemente añadiendo mapas y datos del grafo correspondientes.

