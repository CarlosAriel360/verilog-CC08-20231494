# ProyectoParcial2 Ws in the chat
# CC08 - Detector de comando serial con solapamiento

## 1. Información del estudiante

- **Matrícula:** 20231494
- **Correo institucional:** 20231494@itla.edu.do
- **Reto:** CC08 - Detector de comando serial con solapamiento
- **Lenguaje:** Verilog HDL
- **Repositorio:** https://github.com/CarlosAriel360/verilog-CC08-20231494

## 2. Descripción del proyecto

Este proyecto consiste en desarrollar un circuito digital mediante Verilog capaz de detectar la secuencia binaria `1011` dentro de un flujo de bits recibidos de manera serial.

El circuito utiliza una máquina de estados finitos (FSM) que permite reconocer la secuencia sin necesidad de almacenar todos los bits ingresados. En su lugar, conserva únicamente la información necesaria para determinar cuánto se ha avanzado en la detección.

Cuando el circuito reconoce la secuencia completa, activa una señal llamada `match` durante un ciclo de reloj. Al mismo tiempo, activa una ventana de aviso controlada mediante un contador cuyo valor inicial depende del parámetro `K`.

El detector también permite reconocer secuencias solapadas, es decir, cuando una coincidencia comparte bits con otra.

## 3. Funcionamiento del circuito

El circuito trabaja mediante cuatro estados que representan las diferentes etapas de detección de la secuencia `1011`.

- **Estado 0:** El circuito espera recibir un 1. Si recibe un 0, permanece en este estado.
- **Estado 1:** Ya reconoció el primer 1 y espera recibir un 0 para formar `10`. Si recibe otro 1, permanece en el mismo estado.
- **Estado 2:** Ya reconoció `10` y espera recibir un 1 para formar `101`. Si recibe un 0, regresa al estado 0.
- **Estado 3:** Ya reconoció `101` y espera recibir el último 1 para completar `1011`.

Cuando se completa la secuencia, el circuito activa `match` y regresa al estado 1, conservando el último bit recibido como posible comienzo de otra coincidencia. Si en el estado 3 recibe un 0, regresa al estado 2 porque los últimos dos bits forman `10`.

### Ejemplo de solapamiento

Secuencia recibida: `1011011`

En este caso, el circuito detecta dos coincidencias. La primera termina en el cuarto bit y la segunda termina en el séptimo bit.

Los valores de `match` correspondientes son:

`0, 0, 0, 1, 0, 0, 1`

Esto demuestra cómo el detector puede reconocer dos secuencias compartiendo un mismo bit.

## 4. Arquitectura del circuito

El diseño utiliza lógica secuencial controlada mediante el flanco positivo del reloj `clk`.

Sus componentes principales son:

- **Registro de estado:** Almacena uno de los cuatro estados posibles utilizando dos bits.
- **Registro match:** Indica cuándo se reconoce la secuencia completa.
- **Contador de aviso:** Almacena el tiempo restante durante el cual la señal `aviso` permanece activa.
- **Lógica de control:** Determina el comportamiento del circuito dependiendo de `rst`, `en` y `cmd`.

Las actualizaciones de los registros se realizan mediante asignaciones no bloqueantes (`<=`), utilizando un bloque `always @(posedge clk)`.

Las salidas se conectan mediante instrucciones `assign`.

### Entradas y salidas

| Señal | Función |
|---|---|
| `clk` | Reloj principal del circuito |
| `rst` | Reinicio síncrono activo en alto |
| `en` | Habilitación del funcionamiento |
| `cmd[0]` | Bit recibido |
| `cmd[1]` | Indicador de bit válido |
| `data[7:0]` | Entrada no utilizada en este reto |
| `y[0]` | Señal de coincidencia `match` |
| `y[1]` | Señal de aviso |
| `y[15:2]` | Bits establecidos en cero |

## 5. Prioridades y condiciones especiales

El circuito contempla las siguientes condiciones:

**Reset:** Cuando `rst=1`, en el siguiente flanco positivo del reloj se reinicia el estado, se desactiva `match` y se borra el contador de aviso. Tiene prioridad sobre las demás operaciones.

**Habilitación:** Cuando `en=0`, el detector conserva su estado y el contador mantiene su valor. Sin embargo, `match` se borra en el siguiente flanco, porque debe durar solamente un ciclo.

**Bit válido:** El detector solamente consume un bit cuando `en=1` y `cmd[1]=1`. Si el bit no es válido, no modifica el estado de búsqueda.

**Temporizador:** Cuando se encuentra la secuencia `1011`, el contador de aviso se carga con el valor de `K`. En los siguientes flancos habilitados sin coincidencia, disminuye hasta llegar a cero, incluso cuando `cmd[1]=0`.

**Prioridad de coincidencia:** Si ocurre una nueva coincidencia cuando el contador está por terminar, el contador vuelve a cargarse con `K`, en lugar de disminuir.

## 6. Caso límite: detección con solapamiento

Uno de los casos especiales del circuito ocurre cuando se recibe la secuencia `1010`.

Aunque no corresponde a la secuencia buscada `1011`, sus últimos dos bits forman `10`.

Por esta razón, el detector no regresa al estado 0, sino al estado 2, conservando esa información para continuar buscando una nueva coincidencia.

Este comportamiento es importante para evitar que se pierdan posibles secuencias cuando se reciben muchos bits consecutivos.

## 7. Archivos del proyecto

| Archivo | Descripción |
|---|---|
| `top_module.v` | Implementación principal del detector en Verilog |
| `tb_student.v` | Banco de pruebas automáticas del circuito |
| `README.md` | Documentación del proyecto y del proceso de desarrollo |

## 8. Compilación y simulación

Para ejecutar las pruebas se necesita Icarus Verilog versión 12 o posterior.

Desde la terminal, dentro de la carpeta del repositorio, se utilizan los siguientes comandos:

**Compilación:**

`iverilog -g2012 -s tb_student -o sim top_module.v tb_student.v`

**Ejecución de la simulación:**

`vvp sim`

El primer comando compila el circuito y su banco de pruebas. El segundo ejecuta la simulación.

El archivo generado `sim` no debe incluirse en el repositorio.

## 9. Pruebas y resultados

El banco de pruebas debe verificar automáticamente el comportamiento del circuito para `K=3` y `K=5`.

Los casos que se deben comprobar son:

| Prueba | Resultado |
|---|---|
| Detección normal de `1011` | Pendiente de verificar |
| Dos coincidencias solapadas en `1011011` | Pendiente de verificar |
| Reset durante una secuencia parcial | Pendiente de verificar |
| Pausa mediante `en=0` | Pendiente de verificar |
| Bits inválidos mediante `cmd[1]=0` | Pendiente de verificar |
| Recarga y vencimiento del contador | Pendiente de verificar |
| Funcionamiento con `K=3` y `K=5` | Pendiente de verificar |

**Estado de las pruebas:** pendiente de completar el banco de pruebas y ejecutar la simulación.

Los resultados de esta sección deberán actualizarse después de realizar las comprobaciones automáticas.

## 10. Historial de commits

El proyecto se desarrolla de manera progresiva utilizando Git y GitHub, conservando los cambios realizados en cada etapa.

| Commit (hash) | Avance realizado |
|---|---|
| Pendiente de colocar | Creación de la interfaz y estructura inicial |
| Pendiente de colocar | Implementación parcial de la lógica del detector |
| Pendiente de colocar | Incorporación de pruebas y correcciones |
| Pendiente de colocar | Finalización del circuito y documentación |

Los hashes y las descripciones de esta tabla deben corresponder a commits reales del historial del repositorio.

## 11. Conclusión

Este proyecto permite comprender el funcionamiento de una máquina de estados finitos aplicada al reconocimiento de secuencias binarias.

La implementación utiliza cuatro estados para recordar el avance de la detección, evitando almacenar todos los bits recibidos. También permite trabajar con coincidencias solapadas y controlar una señal temporal mediante un contador parametrizable.

Mediante este ejercicio se aplican conceptos de lógica secuencial, registros, condiciones de control, temporización y descripción de hardware utilizando Verilog.