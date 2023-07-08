`timescale 1ns / 1ps

module bcd_counter(clk, rst, bcd);
    input clk, rst;
    output [3:0]bcd;
    
    reg [3:0]a,t,s;

    integer i;
    initial begin
        a = 4'b0;
    end

    always @(posedge clk) begin
        if(rst)
            t = 4'b0000;
        else
            t = a + 4'b1;
            if(t > 4'h9)
                t = t + 6;
            else
                t = t;
            a = t;
    end
    assign bcd = t;
endmodule
