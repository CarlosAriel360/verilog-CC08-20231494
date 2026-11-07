module top_module #(parameter integer K = 3) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [7:0] cmd,
    input wire [7:0] data,
    output wire [15:0] y
);

    reg [1:0] estado;
    reg match;
    reg [3:0] contador_aviso;

    assign y[0] = match; 
    assign y[1] = (contador_aviso > 4'd0);
    assign y[15:2] = 14'b00000000000000;

     always @(posedge clk) begin

          if (rst == 1'b1) begin
            estado <= 2'd0;
            match <= 1'b0;
            contador_aviso <= 4'd0;
        end
    