`timescale 1ns / 1ps

module fletcher64_checksum (
    input clk,
    input rst,
    input en,
    input [63:0] addr[63:0],
    input [63:0] len,
    input [63:0] csum,
    output reg [63:0] seq
);

reg [31:0] lo32;
reg [31:0] hi32;
reg toggle_checksum;
reg [63:0] counter_checksum;
reg [63:0] length_traversed;
reg end_of_length;

always @(posedge clk) begin
    if(~rst) begin
        toggle_checksum <= 0;
        length_traversed <= 0;
    end
end

always @ (en) begin
    if(en) begin
        toggle_checksum = 1;
        length_traversed = 0;
    end
    else begin 
        toggle_checksum = 0;
        length_traversed = 0;
    end
end

always @(posedge clk) begin
    if(toggle_checksum) begin
        counter_checksum <= 0;
        if(length_traversed <= len) begin
            length_traversed <= length_traversed + 1'b1;
            end_of_length <= 1;
        end
        else begin
            end_of_length <= 0;
        end
    end
    else if(~rst) begin
        end_of_length = 0;
    end
end

always @ (posedge clk) begin
    if(end_of_length) begin
        lo32 <= lo32 + addr[31:0][(8*length_traversed) +: 8];
        hi32 <= hi32 + lo32 + addr[31:0][(8*length_traversed) +: 8];     
    end
    else if(~rst) begin
        lo32 <= csum[31:0];
        hi32 <= csum[63:32];
    end
    else if(~end_of_length) begin
        seq <= hi32 << 32 | lo32;     
    end
end

endmodule