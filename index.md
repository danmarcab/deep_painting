# Deep Painting

## Arquitectura inicial

![Arquitectura Inicial](ArquitecturaInicial.png)

En el diagrama se pueden ver los pricipales componentes y como se comunican entre ellos. A continuación sigue 
una breve explicacion de cada uno de ellos.

### Gallery

Es la applicacion que inicia, almacena, coordina y expone la intefaz de las imágenes.

Está escrita en elixir, un lenguage funcional y altamente concurrente que corre en la máquina virtual de erlang.

Se comunica con Gallery UI mediante `Phoenix channels`, un protocolo del framework `Phoenix` basado en websockets.
Se comunica con Pycasso mediante `Erlang ports`, un mecanismo de comunicación entre processos basado en `pipes`.

### Gallery UI 

Es la interfaz web de Gallery.

Desde ella el usuario puede iniciar o ver el estado de las imágenes creadas hasta ahora.

Está escrita en elm, un lenguaje funcional puro con sintaxis similar a haskell.

Se comunica con Gallery mediante `Phoenix channels`, un protocolo del framework `Phoenix` basado en websockets.


### Pycasso

Es la applicacion que usa deep learning para crear las imágenes. 

Está escrita en python, un lenguaje orientado a objetos que la comunidad científica esta tendiendo a usar. Usa
`tensorflow` y otras librerías de apoyo para ejecutar una variante de la red neuronal `VGG19`, que consiste de 
19 capas.

Se comunica con Gallery mediante `Erlang ports`, un mecanismo de comunicación entre processos basado en `pipes`.


## Problema: Lentitud

Debido al gran tamaño de la red neuronal, generar una imágen de 400px de alto (sólo 10 iteraciones)  puede 
llevar en torno a 1 hora y media usando solo CPU. Dado que conseguir buenas imágenes precisa de intentos
modificando los parámetros, este rendimiento no es aceptable.

La solucion es usar GPU, que puede hacer en proceso hasta 30-60 veces mas rápido. Dado que no cuento con un
ordenador en el cual usar la GPU, la decision fue dividir la applicación para asi poder correr la parte de
computación intensiva en la nube.

## Nueva Arquitectura

La idea es dividir Galery en dos partes. De este modo la parte que se comunica con Pycasso (se llamará Studio) 
puede estar en un servidor y la parte que se comunica con Gallery UI (que seguira siendo Gallery) en otro. 
Las partes comunes fueron extraidas a otra tercera applicación llamada Painting.

Esta división permite tener todas las aplicaciones juntas en un servidor como en el siguiente diagrama:

![Arquitectura Inicial](Arquitectura.png)

Y también permite tener las aplicaciones separadas en dos servidores como en el siguiente diagrama:

![Arquitectura Inicial](Arquitectura_2.png)
