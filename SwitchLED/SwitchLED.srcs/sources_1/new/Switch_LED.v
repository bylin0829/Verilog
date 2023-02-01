`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/01 11:12:29
// Design Name: 
// Module Name: Switch_LED
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


module Switch_LED(
    input [15:0] sw,
    output [15:0] led
    );

assign led[15:0] = sw[15:0]; 

endmodule
