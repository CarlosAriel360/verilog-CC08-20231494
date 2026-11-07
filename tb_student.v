
module tb_student;

    // Entradas que vamos a controlar.
    reg clk;
    reg rst;
    reg en;
    reg [7:0] cmd;
    reg [7:0] data;

    // Salidas de los circuitos que vamos a probar.
    wire [15:0] y_k3;
    wire [15:0] y_k5;

    integer numero_ciclo;

    // Primer circuito: K = 3.
    top_module #(.K(3)) detector_k3 (
        .clk(clk),
        .rst(rst),
        .en(en),
        .cmd(cmd),
        .data(data),
        .y(y_k3)
    );

    // Segundo circuito: K = 5.
    top_module #(.K(5)) detector_k5 (
        .clk(clk),
        .rst(rst),
        .en(en),
        .cmd(cmd),
        .data(data),
        .y(y_k5)
    );

    // Generamos el reloj.
    always #5 clk = ~clk;

    // Esta tarea realiza una prueba completa de un ciclo.
    task comprobar_ciclo;

        input nuevo_rst;
        input nuevo_en;
        input nuevo_valid;
        input nuevo_bit;
        input [1:0] esperado_k3;
        input [1:0] esperado_k5;

        begin
            // Colocamos las entradas antes del flanco positivo.
            @(negedge clk);

            rst = nuevo_rst;
            en = nuevo_en;
            cmd[1] = nuevo_valid;
            cmd[0] = nuevo_bit;

            // Esperamos el flanco positivo del reloj.
            @(posedge clk);

            // Esperamos a que se actualicen las salidas.
            #1;

            numero_ciclo = numero_ciclo + 1;

            // Comprobamos K = 3.
            if (y_k3[1:0] !== esperado_k3) begin
                $fatal(1, "ERROR en ciclo %0d con K=3",
                       numero_ciclo);
            end

            // Comprobamos K = 5.
            if (y_k5[1:0] !== esperado_k5) begin
                $fatal(1, "ERROR en ciclo %0d con K=5",
                       numero_ciclo);
            end

            // Los otros 14 bits deben valer cero.
            if (y_k3[15:2] !== 14'd0) begin
                $fatal(1, "ERROR en bits superiores K=3");
            end

            if (y_k5[15:2] !== 14'd0) begin
                $fatal(1, "ERROR en bits superiores K=5");
            end

            $display("Ciclo %0d correcto", numero_ciclo);
        end

    endtask

    // Comenzamos la simulacion.
    initial begin

        // Valores iniciales.
        clk = 1'b0;
        rst = 1'b0;
        en = 1'b0;
        cmd = 8'b00000000;
        data = 8'b00000000;
        numero_ciclo = 0;

        // PRUEBA 1: RESET Y SECUENCIA 1011011

        comprobar_ciclo(1, 0, 0, 0, 2'b00, 2'b00);

        // Introducimos el primer 1.
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Introducimos 0.
        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);

        // Introducimos 1.
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Introducimos 1: primera coincidencia.
        comprobar_ciclo(0, 1, 1, 1, 2'b11, 2'b11);

        // Introducimos 0.
        comprobar_ciclo(0, 1, 1, 0, 2'b10, 2'b10);

        // Introducimos 1.
        comprobar_ciclo(0, 1, 1, 1, 2'b10, 2'b10);

        // Introducimos 1: segunda coincidencia.
        comprobar_ciclo(0, 1, 1, 1, 2'b11, 2'b11);

        // PRUEBA 2: PAUSA

        // en=0: se conserva el temporizador.
        comprobar_ciclo(0, 0, 1, 1, 2'b10, 2'b10);

        // PRUEBA 3: TEMPORIZADOR CON VALID=0

        comprobar_ciclo(0, 1, 0, 1, 2'b10, 2'b10);
        comprobar_ciclo(0, 1, 0, 0, 2'b10, 2'b10);

        // Aqui termina el aviso para K=3.
        comprobar_ciclo(0, 1, 0, 0, 2'b00, 2'b10);

        comprobar_ciclo(0, 1, 0, 1, 2'b00, 2'b10);

        // Aqui termina el aviso para K=5.
        comprobar_ciclo(0, 1, 0, 0, 2'b00, 2'b00);

        // PRUEBA 4: RESET CON SECUENCIA INCOMPLETA

        comprobar_ciclo(1, 0, 0, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Reset tiene prioridad, aunque llegue un 1.
        comprobar_ciclo(1, 1, 1, 1, 2'b00, 2'b00);

        // Volvemos a construir 1011.
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b11, 2'b11);

        // Reset con el aviso encendido.
        comprobar_ciclo(1, 0, 0, 0, 2'b00, 2'b00);

        // PRUEBA 5: BIT INVALIDO ENTRE BITS VALIDOS

        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Este 0 se ignora porque valid=0.
        comprobar_ciclo(0, 1, 0, 0, 2'b00, 2'b00);

        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b11, 2'b11);

        // PRUEBA 6: CONSERVAR 10 DESPUES DE 1010

        comprobar_ciclo(1, 0, 0, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);
        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Tenemos 1010: el detector conserva 10.
        comprobar_ciclo(0, 1, 1, 0, 2'b00, 2'b00);

        comprobar_ciclo(0, 1, 1, 1, 2'b00, 2'b00);

        // Se completa otra coincidencia.
        comprobar_ciclo(0, 1, 1, 1, 2'b11, 2'b11);

        $display("TODAS LAS PRUEBAS PASARON");
        $finish;
    end

endmodule
