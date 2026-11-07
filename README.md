# CC08 — Detector de comando serial con solapamiento

## 1. Datos del estudiante

- **Matrícula:** 20231494
- **Correo institucional:** 20231494@itla.edu.do
- **Reto:** CC08 — Detector de comando serial con solapamiento
- **Lenguaje:** Verilog HDL (compatible con Verilog 2001)
- **Repositorio:** https://github.com/CarlosAriel360/verilog-CC08-20231494

## 2. Objetivo del proyecto

Diseñar un circuito digital que reciba bits de forma serial y reconozca la secuencia `1011`, incluso cuando dos coincidencias comparten algún bit (solapamiento). Al detectar la secuencia, el circuito activa la señal `match` durante un ciclo de reloj y carga un contador que mantiene activa la señal `aviso` mientras su valor sea mayor que cero.

No se requiere una tarjeta FPGA: el funcionamiento se comprueba mediante simulación.

## 3. Funcionamiento y arquitectura

El circuito utiliza una **máquina de estados finitos (FSM)**. En lugar de guardar todos los bits recibidos, un registro de dos bits (`estado`) recuerda qué parte útil de `1011` se ha reconocido.

| Estado | Información recordada | Qué espera |
|---|---|---|
| `2'd0` | Ningún prefijo útil | `1` |
| `2'd1` | `1` | `0` |
| `2'd2` | `10` | `1` |
| `2'd3` | `101` | `1` para completar `1011` |

Cuando el detector está en el estado `2'd3` y recibe un `1` válido, reconoce `1011`, activa `match` y pasa al estado `2'd1`. Este cambio conserva el último `1`, que también puede servir como comienzo de la siguiente coincidencia.

Además, se utilizan los registros `match` (pulso de coincidencia) y `contador_aviso` (contador de cuatro bits). El contador se carga con el parámetro entero `K`, cuyo valor permitido está entre 2 y 8. Si no hay otra coincidencia, disminuye en cada flanco habilitado hasta llegar a cero.

El diseño utiliza un único bloque `always @(posedge clk)` para actualizar los registros, reset síncrono y asignaciones no bloqueantes (`<=`). Las salidas se conectan con `assign`.

## 4. Entradas y salidas

| Señal | Función |
|---|---|
| `clk` | Reloj del circuito; los registros cambian en el flanco positivo. |
| `rst` | Reset síncrono, activo en alto y con máxima prioridad. |
| `en` | Habilita el consumo de bits y el avance del temporizador. |
| `cmd[0]` | Bit recibido, `0` o `1`. |
| `cmd[1]` | Indica si el bit recibido es válido. |
| `cmd[7:2]` | Bits no utilizados; se ignoran. |
| `data[7:0]` | Entrada no utilizada en este reto. |
| `y[0]` | `match`: vale `1` cuando se detecta `1011`. |
| `y[1]` | `aviso`: vale `1` mientras el contador sea mayor que cero. |
| `y[15:2]` | Siempre valen cero. |

## 5. Prioridades y casos especiales

- **Reset (`rst=1`):** borra el estado, `match` y el contador, aunque las demás entradas estén activas.
- **Pausa (`en=0`):** conserva el estado y el contador, pero `match` se borra en el siguiente flanco.
- **Bit inválido (`cmd[1]=0`):** el detector no consume ese bit. Si `en=1`, el contador de aviso sigue disminuyendo cuando no hay coincidencia.
- **Coincidencia:** tiene prioridad sobre el decremento del contador. Si aparece otro `1011`, el contador vuelve a cargarse con `K`.
- **Solapamiento:** después de reconocer `1011`, se conserva el último `1` volviendo al estado `2'd1`.

**Caso límite:** si los bits válidos recibidos forman `1010`, no hay coincidencia, pero los últimos dos bits son `10`. Por eso el detector pasa al estado `2'd2` en lugar de regresar al estado inicial.

## 6. Ejemplo de funcionamiento

Para la secuencia válida `1011011`, las coincidencias aparecen en el cuarto y séptimo bit:

| Bit recibido (posición) | 1 | 0 | 1 | 1 | 0 | 1 | 1 |
|---|---|---|---|---|---|---|---|
| Posición | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| `match` | 0 | 0 | 0 | 1 | 0 | 0 | 1 |

Con `K=3`, el contador de aviso se carga con 3 en la primera coincidencia y se vuelve a cargar con 3 cuando ocurre la segunda.

## 7. Archivos del repositorio

- **`top_module.v`:** descripción del circuito sintetizable.
- **`tb_student.v`:** banco de pruebas con comprobaciones automáticas.
- **`README.md`:** explicación del proyecto, instrucciones y resultados.

## 8. Cómo compilar y ejecutar las pruebas

Se requiere **Icarus Verilog 12 o posterior**. Desde la carpeta raíz del repositorio:

1. Comprobar la versión instalada: `iverilog -V`
2. Compilar: `iverilog -g2012 -s tb_student -o sim top_module.v tb_student.v`
3. Ejecutar: `vvp sim`

El archivo generado `sim` es un ejecutable de simulación y **no debe subirse al repositorio**.

## 9. Resultados de las pruebas propias

Se compiló `top_module.v` junto con `tb_student.v` y se ejecutaron las pruebas en Ubuntu desde Visual Studio Code utilizando Icarus Verilog. El testbench comprueba las configuraciones **`K=3` y `K=5`** en cada ciclo y compara las salidas obtenidas con las esperadas.

| Prueba realizada | Resultado observado |
|---|---|
| Detección de la secuencia `1011` | Aprobada |
| Dos coincidencias solapadas en `1011011` | Aprobada |
| Pausa con `en=0` | Aprobada |
| Avance del temporizador con `cmd[1]=0` | Aprobada |
| Reset durante una secuencia incompleta y con aviso activo | Aprobada |
| Ignorar bits inválidos | Aprobada |
| Conservación del prefijo `10` después de `1010` | Aprobada |
| Comparaciones para `K=3` y `K=5` | Aprobadas |

**Resultado de la ejecución:** 36 ciclos comprobados correctamente, sin errores reportados por el testbench.

Último mensaje de la terminal: `TODAS LAS PRUEBAS PASARON`.

La simulación finalizó normalmente mediante `$finish`, en la línea 193 de `tb_student.v`.

**Alcance:** estos resultados corresponden a las pruebas propias ejecutadas. No representan la aprobación de las pruebas ocultas del docente ni de los 900 ciclos pseudoaleatorios previstos en su evaluación.

## 10. Historial de desarrollo en GitHub

El historial del repositorio conserva los avances realizados durante el desarrollo. La tabla siguiente debe completarse con **hashes reales** y descripciones que correspondan a cambios verificables en el repositorio.

| Hash completo del commit | Avance realizado |
|---|---|
| `PENDIENTE: hash real` | Interfaz, estructura inicial y planificación. |
| `PENDIENTE: hash real` | Implementación parcial funcional del detector. |
| `PENDIENTE: hash real` | Pruebas automáticas y depuración. |
| `PENDIENTE: hash real` | Solución final y documentación. |

Para consultar el historial desde la terminal: `git log --format="%H %s" --reverse`.

**Commit final para entregar al profesor:** `PENDIENTE: agregar el hash completo del commit final después de hacer la última confirmación`.

## 11. Conclusión

El proyecto permitió implementar y verificar un detector de secuencias seriales utilizando una máquina de estados finitos. El circuito recuerda únicamente el prefijo necesario, detecta coincidencias solapadas y controla una ventana temporal de aviso mediante el parámetro `K`. Las 36 pruebas propias realizadas en las configuraciones `K=3` y `K=5` finalizaron correctamente.