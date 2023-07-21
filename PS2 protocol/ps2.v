`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 15:52:30
// Design Name: 
// Module Name: ps2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ps2(clk, ps2ck, ps2d, rst, seg, cc);
    //100 MHz crystal
    input clk, rst;
    input ps2ck, ps2d;
    output reg [6:0]seg;
    output cc;

    //1ms counter
    parameter D0 = 100000 -1;
    reg [16:0]cnt_1ms;
    wire stb_1ms = (cnt_1ms == D0);
    always @(posedge clk) begin
        if(rst | stb_1ms) cnt_1ms <= 17'b0;
        else cnt_1ms <= cnt_1ms + 17'b1; 
    end

    //100ms counter
    parameter D1 = 50 -1;
    reg [7:0]cnt_50ms;
    wire stb_50ms = stb_1ms & (cnt_50ms == D1);
    always@(posedge clk)begin
        if(rst | stb_50ms) cnt_50ms <= 8'b0;
        else if(stb_1ms) cnt_50ms <= cnt_50ms + 8'b1;
    end

    //LED selector
    reg [1:0]scan;
    wire d4m_stb = stb_1ms & (scan == 2'b11);
    always@(posedge clk) begin
        if(rst) scan <= 2'h0;
        else if (stb_1ms) scan <= scan + 2'h1;
    end

    /*******PS2 kb********/
    // edge detection & falling edge detection
    reg ps2ck_r1, ps2ck_r2;
    wire edge_detect = ps2ck_r1 ^ ps2ck_r2;
    wire fall_edge = edge_detect & ~ps2ck_r1;
    always@(posedge clk) {ps2ck_r2, ps2ck_r1} <= {ps2ck_r1, ps2ck};

    //state machine
    reg [4:0] state, state_nxt;
    parameter IDLE   = 5'b00001;
    parameter DATA   = 5'b00010;
    parameter PAR    = 5'b00100;
    parameter STOP   = 5'b01000;
    parameter ERR    = 5'b10000;

    wire last_bit, bit11;
    always@(*)begin
        if(fall_edge)begin
            case(state)
                IDLE: state_nxt = (~ps2d) ? DATA : ERR;
                DATA: state_nxt = last_bit ? PAR : DATA;
                PAR:  state_nxt = STOP;
                STOP: state_nxt = IDLE;
                ERR:  state_nxt = bit11 ? IDLE : ERR;
                default: state_nxt = IDLE;
            endcase
        end
        else state_nxt = state;
    end
    
    //implement FF to transparent state
    always@(posedge clk)begin
        if(rst) state <= IDLE;
        else state <= state_nxt;
    end
    
    wire state_idle = (state == IDLE);
    wire state_data = (state == DATA);
    wire state_par  = (state == PAR);
    wire state_stop = (state == STOP);
    wire state_err  = (state == ERR);

    // bit counter
    reg [3:0] bit_counter;
    assign last_bit = fall_edge & (bit_counter == 4'h7);
    assign bit11 = fall_edge & (bit_counter == 4'h9);
    always@(posedge clk) begin
        if(rst | state_idle) bit_counter <= 4'h0;
        else if(fall_edge) bit_counter <= bit_counter + 4'h1;
    end

    //serial data shift register
    reg[7:0] sftreg;
    always@(posedge clk) begin
        if(rst) sftreg <= 8'h0;
        else if(state_data & fall_edge) sftreg <= {ps2d, sftreg[7:1]};
    end

    // parity check
    reg par;
    always@(posedge clk) begin
        if(rst | state_idle) par <= 1'b1;
        else if((state_data | state_par) & fall_edge) par <= ps2d ^ par;
    end

    wire valid_data = state_stop & fall_edge & ps2d & ~par;

    // send make code and break code
    reg make_code, break_code;
    always@(posedge clk)begin
        if(rst) make_code <= 1'b0;
        else if(~make_code & ~break_code & valid_data & (sftreg != 8'hf0)) make_code <= 1'b1;
        else if( make_code &  break_code & valid_data & (sftreg != 8'hf0)) make_code <= 1'b0;
    end


    always@(posedge clk)begin
        if(rst) break_code <= 1'b0;
        else if( make_code & ~break_code & valid_data & (sftreg == 8'hf0)) break_code <= 1'b1;
        else if( make_code &  break_code & valid_data & (sftreg != 8'hf0)) break_code <= 1'b0;
    end

    //set BCD number
    reg [15:0]dig_cnt;
    always@(posedge clk) begin
        if(rst) dig_cnt <= 4'h0;
        else if(valid_data) dig_cnt <= {8'h0, sftreg};
    end

    //2 to 1 mux for seg7 selection
    reg [3:0] bcd_sel;
    always@(*)begin
        case(scan[0])
            1'b0: begin
                bcd_sel = dig_cnt[3:0];
            end
            1'b1: begin
                bcd_sel = dig_cnt[7:4];
            end
        endcase
    end

    //7-seg decoder
    always@(*)begin
        if(make_code)begin
            case(bcd_sel)
                4'h0 : seg = 7'b011_1111;
                4'h1 : seg = 7'b000_0110;
                4'h2 : seg = 7'b101_1011;
                4'h3 : seg = 7'b100_1111;
                4'h4 : seg = 7'b110_0110;
                4'h5 : seg = 7'b110_1101;
                4'h6 : seg = 7'b111_1101;
                4'h7 : seg = 7'b000_0111;
                4'h8 : seg = 7'b111_1111;
                4'h9 : seg = 7'b110_1111;
                4'd10 : seg = 7'b111_0111;
                4'd11 : seg = 7'b111_1100;
                4'd12 : seg = 7'b011_1001;
                4'd13 : seg = 7'b101_1110;
                4'd14 : seg = 7'b111_1001;
                4'd15 : seg = 7'b111_0001;
                default: seg = 7'b000_0000;
            endcase
        end
        else seg = 7'b0;
    end
    assign cc = scan[0];
endmodule