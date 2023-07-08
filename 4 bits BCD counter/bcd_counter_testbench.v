`timescale 1ns / 1ps

module bcd_counter_testbench;
    reg clk,rst;
    wire [3:0]bcd;

    integer i;

    initial begin
        clk = 1'b0; rst = 1'b0;
        // #1 clk = 1'b0;
        // #1 rst = 1'b1;
        // #1 clk = 1'b1;
        // #1 clk = 1'b0;
        // #1 rst = 1'b0;

        for(i = 0; i < 30; i=i+1)
            #2 clk = ~clk;

        #1 clk = 1'b0;
        #1 rst = 1'b1;
        #1 clk = 1'b1;
        #1 clk = 1'b0;
        #1 rst = 1'b0;
        for(i = 0; i < 25; i=i+1)
            #1 clk = ~clk;
        
        $finish;
    end
    
    bcd_counter UUT(
        .clk(clk),
        .rst(rst),
        .bcd(bcd)
        );
endmodule
