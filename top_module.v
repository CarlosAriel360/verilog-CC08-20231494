module top_module #(parameter integer K = 3) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [7:0] cmd,
    input wire [7:0] data,
    output wire [15:0] y
);

    reg [1:0] estado;
