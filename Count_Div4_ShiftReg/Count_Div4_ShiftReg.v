`timescale 1ns / 1ps

module Count_Div4_ShiftReg(clk, rst_n, cnt, sftreg, ld, sw);
    input clk, rst_n, ld;
    input [3:0] sw;

    output [5:0] sftreg;
    output [3:0] cnt;

    wire rst = ~rst_n;
    
    //4 bits counter
    reg [3:0] cnt;
    always @(posedge clk) begin
        if (rst) cnt <= 4'b0;
        else if (ld) cnt <= sw;
        else cnt <= cnt + 4'b1;
    end

    //divider 4
    reg [1:0]div4_cnt;
    wire d4_stb = (div4_cnt[1:0] == 2'b11);
    always @(posedge clk) begin
        if (rst) div4_cnt <= 2'b0;
        else div4_cnt <= (div4_cnt + 1'b1);
    end

    //6 bits shift register
    reg [5:0]sftreg;
    initial sftreg = 6'b000001;
    always @(posedge clk) begin
        if (rst)
            sftreg <= 6'b000001;
        else if (d4_stb) begin
            if (sftreg[5]) sftreg = 6'b000001;
            else sftreg <= {sftreg[4:0], 1'b0};
        end
    end
endmodule
