`timescale 1ns / 1ps

module tb_checksum;

reg clk, rst, valid;
reg [63:0] data;
reg [63:0] csum;
wire [63:0] seq;

fletcher64_checksum uut(clk, rst, valid, data, csum, seq);

initial begin
clk = 0;
forever #10 clk = ~clk;
end

initial begin
rst = 0;
valid = 0;
#15 
rst = 1;
valid = 1;
data = 64'd163;
csum = 0;
#60
$finish;
end
endmodule
