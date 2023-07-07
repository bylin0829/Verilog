`timescale 1ns / 1ps

module Count_Div4_ShiftReg_testbench;
    reg clk, rst_n, ld;
    reg [3:0]sw;
    wire [3:0]cnt;
    wire [5:0]sftreg;

initial begin
    clk = 0;
    #1;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 1; ld = 0; sw = 0;
    #100 rst_n = 0;
    #1000 rst_n = 1;
    repeat(32)@(posedge clk);
    #1; ld = 1; sw = 4'b0110;
    repeat(4)@(posedge clk);
    ld = 0;
    repeat(32)@(posedge clk);
    #1; ld = 1; sw = 4'b1001;
    repeat(4)@(posedge clk);
    ld = 0;

    repeat(32)@(posedge clk);
    $display($time, "Simulation Done!!");
    $finish;
end

Count_Div4_ShiftReg dut(
    .clk(clk),
    .rst_n(rst_n),
    .cnt(cnt),
    .sftreg(sftreg),
    .ld(ld),
    .sw(sw));
endmodule
