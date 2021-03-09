`timescale 1ns / 1ps

module adress_checker(
    input clk,
    input rst,
    input [63:0] address,         //byte-addressable memory
    input [63:0] size,            //size is assumed to be in bytes 
    input valid,                  //signifies incoming address and size 
    output reg [1:0] dependency   //00 -> Incoming address range independent of existing processes' address ranges
                                  //01 -> Incoming address range clashing with existing address ranges
                                  //11 -> Process buffer full with 4 address ranges already being processes. No space for new incoming process
    );

reg [63:0] address_buffer [0:2];
reg [63:0] end_address_buffer [0:2];
reg [63:0] size_buffer [0:2];
reg [3:0] count;
reg decision;

wire [63:0] end_address;
wire [3:0] count_wire;

assign count_wire = count;
assign end_address = address + size - 1'b1;

always @ (posedge clk) begin
    if(~rst) begin
        dependency <= 0;
    end
    else if(valid) begin
        case (count_wire)
            2'b00:  dependency <= 0; 
            2'b01:  begin
                        if(decision) dependency <= 0;
                        else dependency <= 1;
                    end
            2'b10:  begin
                         if(decision) dependency <= 0;
                         else dependency <= 1;
                    end 
            2'b11:  dependency <= 2'b11;  
        endcase
    end  
end

always @ (posedge clk) begin
    if(~rst) begin
    for(int i=0;i<4;i++) begin
        address_buffer[i] <= 0;
        size_buffer[i] <= 0;  
        end_address_buffer[i] <= 0;
    end 
        count <= 0;
    end
    else if(valid & count_wire != 2'b11) begin
            count <= count + 1'b1;
            case (count_wire)
                2'b00:  begin 
                            address_buffer[0] <= address;
                            size_buffer[0] <= size;
                            end_address_buffer[0] <= address + size - 1'b1;
                        end
                2'b01:  begin 
                                address_buffer[1] <= address;
                                size_buffer[1] <= size;
                                end_address_buffer[1] <= address + size - 1'b1;
                         end                    
                 2'b10:  begin 
                                 address_buffer[2] <= address;
                                 size_buffer[2] <= size;
                                 end_address_buffer[2] <= address + size - 1'b1;
                         end
                 /*2'b11:  begin 
                                  address_buffer[3] <= address;
                                  size_buffer[3] <= size;
                                  end_address_buffer[3] <= address + size - 1'b1;
                         end*/
            endcase             
    end
end

always @(valid) begin
    if(valid) begin
        case (count_wire)
            2'b00: begin
                        decision = 1;    //decision <- 1 implies no dependency
                   end
            2'b01: begin
                         if((address <= address_buffer[0] & end_address >= address_buffer[0]) | 
                         (address <= end_address_buffer[0] & end_address >= address_buffer[0]))
                            decision = 0;
                         else decision = 1;
                   end
            2'b01: begin
                         if((end_address < address_buffer[0] & end_address < address_buffer[1]) | 
                         (address > end_address_buffer[0] & end_address < address_buffer[1]) | 
                         (address > end_address_buffer[1] & end_address < address_buffer[0]) | 
                         (address > end_address_buffer[0] & address > end_address_buffer[1]))
                            decision = 1;
                         else decision = 0; 
                   end 
            2'b10: begin
                         if((end_address < address_buffer[0] & end_address < address_buffer[1] & end_address < address_buffer[2]) | 
                         (address > end_address_buffer[0] & address > end_address_buffer[1] & address > end_address_buffer[2]))
                            decision = 1;
                         else decision = 0;
                   end  
        endcase   
    end
    else begin
        decision = 0;
    end
end

endmodule


