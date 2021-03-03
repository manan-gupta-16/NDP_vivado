`timescale 1ns / 1ps

module tb_address_checker;

reg clk, rst, valid;
wire [1:0] dependency;
reg [63:0] address;
reg [63:0] size;

adress_checker uut(clk, rst, address, size, valid, dependency);

initial begin
clk = 0;
forever #10 clk = ~clk;
end 

initial begin
rst = 0;
address = 0;
size = 0;
valid = 0;
#30
rst = 1;
valid = 1;
address = 64'd123;
size = 64'd3;
#10
rst = 1;
valid = 0;
address = 64'd123;
size = 64'd3;
#40
rst = 1;
valid = 1;
address = 64'd124;
size = 64'd4;
#40
$finish;
end

endmodule

