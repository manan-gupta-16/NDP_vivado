`timescale 1ns / 1ps

module fletcher64_checksum (
    input clk,
    input rst,
    input valid,
    input [63:0] data,
    input [63:0] csum,
    output [63:0] seq
);

reg [31:0] lo32;
reg [31:0] hi32;

assign seq = (hi32 << 32) | lo32;

always @ (posedge clk) begin
    if(~rst) begin
        lo32 <= 0;
        hi32 <= 0;
    end
    else if(valid) begin
        lo32 <= csum[31:0] + data[31:0];
        hi32 <= csum[63:32] + csum[31:0] + data[31:0];
    end
end
endmodule