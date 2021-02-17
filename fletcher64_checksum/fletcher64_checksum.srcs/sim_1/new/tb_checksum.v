`timescale 1ns / 1ps

module tb_checksum;

reg clk, rst, en;
reg [63:0] addr[63:0];
reg [63:0] len;
reg [63:0] csum;
wire [63:0] seq;

fletcher64_checksum uut(clk, rst, en, addr, len, csum, seq);

initial begin
clk = 0;
forever #10 clk = ~clk;
end

initial begin
rst = 0;
en = 0;
#15 
rst = 1;
en = 1;
addr = {32'd163, 32'd200, 32'd19, 32'd74, 32'd88};
len = 64'd5;
csum = 0;
#60
$finish;
end
endmodule
