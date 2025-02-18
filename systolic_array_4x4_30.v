`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2024 15:48:56
// Design Name: 
// Module Name: systolic_array_4x4_30
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

module systolic_array_4x4 #(parameter N = 16) ( 
    input wire clk_30, 
    input wire reset_30, 
    input wire [N-1:0] A_00_30, A_01_30, A_02_30, A_03_30, 
    input wire [N-1:0] A_10_30, A_11_30, A_12_30, A_13_30, 
    input wire [N-1:0] A_20_30, A_21_30, A_22_30, A_23_30, 
    input wire [N-1:0] A_30_30, A_31_30, A_32_30, A_33_30, 
    input wire [N-1:0] B_00_30, B_01_30, B_02_30, B_03_30, 
    input wire [N-1:0] B_10_30, B_11_30, B_12_30, B_13_30, 
    input wire [N-1:0] B_20_30, B_21_30, B_22_30, B_23_30, 
    input wire [N-1:0] B_30_30, B_31_30, B_32_30, B_33_30, 
    output reg [N-1:0] Z_00_30, Z_01_30, Z_02_30, Z_03_30, 
    output reg [N-1:0] Z_10_30, Z_11_30, Z_12_30, Z_13_30, 
    output reg [N-1:0] Z_20_30, Z_21_30, Z_22_30, Z_23_30, 
    output reg [N-1:0] Z_30_30, Z_31_30, Z_32_30, Z_33_30, 
    output reg output_valid_30 
); 

    reg [N-1:0] A_reg_30 [3:0][3:0]; 
    reg [N-1:0] B_reg_30 [3:0][3:0]; 
    wire [N-1:0] Z_internal_30 [3:0][3:0]; 
    wire [15:0] pushout_wires_30; // Flattened array for pushout signals 
    integer i_30, j_30; 

    // Initialize matrices A and B, and set outputs to 0 on reset 
    always @(posedge clk_30 or posedge reset_30) begin 
        if (reset_30) begin 
            for (i_30 = 0; i_30 < 4; i_30 = i_30 + 1) begin 
                for (j_30 = 0; j_30 < 4; j_30 = j_30 + 1) begin 
                    A_reg_30[i_30][j_30] <= 0; 
                    B_reg_30[i_30][j_30] <= 0; 
                end 
            end 
            Z_00_30 <= 0; Z_01_30 <= 0; Z_02_30 <= 0; Z_03_30 <= 0; 
            Z_10_30 <= 0; Z_11_30 <= 0; Z_12_30 <= 0; Z_13_30 <= 0; 
            Z_20_30 <= 0; Z_21_30 <= 0; Z_22_30 <= 0; Z_23_30 <= 0; 
            Z_30_30 <= 0; Z_31_30 <= 0; Z_32_30 <= 0; Z_33_30 <= 0; 
            output_valid_30 <= 0; 
        end else begin 
            // Load inputs into A and B matrices 
            A_reg_30[0][0] <= A_00_30; A_reg_30[0][1] <= A_01_30; A_reg_30[0][2] <= A_02_30; A_reg_30[0][3] <= A_03_30; 
            A_reg_30[1][0] <= A_10_30; A_reg_30[1][1] <= A_11_30; A_reg_30[1][2] <= A_12_30; A_reg_30[1][3] <= A_13_30; 
            A_reg_30[2][0] <= A_20_30; A_reg_30[2][1] <= A_21_30; A_reg_30[2][2] <= A_22_30; A_reg_30[2][3] <= A_23_30; 
            A_reg_30[3][0] <= A_30_30; A_reg_30[3][1] <= A_31_30; A_reg_30[3][2] <= A_32_30; A_reg_30[3][3] <= A_33_30; 
            B_reg_30[0][0] <= B_00_30; B_reg_30[0][1] <= B_01_30; B_reg_30[0][2] <= B_02_30; B_reg_30[0][3] <= B_03_30; 
            B_reg_30[1][0] <= B_10_30; B_reg_30[1][1] <= B_11_30; B_reg_30[1][2] <= B_12_30; B_reg_30[1][3] <= B_13_30; 
            B_reg_30[2][0] <= B_20_30; B_reg_30[2][1] <= B_21_30; B_reg_30[2][2] <= B_22_30; B_reg_30[2][3] <= B_23_30; 
            B_reg_30[3][0] <= B_30_30; B_reg_30[3][1] <= B_31_30; B_reg_30[3][2] <= B_32_30; B_reg_30[3][3] <= B_33_30; 
        end 
    end 

    genvar row_30, col_30; 
    generate 
        for (row_30 = 0; row_30 < 4; row_30 = row_30 + 1) begin : row_loop_30 
            for (col_30 = 0; col_30 < 4; col_30 = col_30 + 1) begin : col_loop_30 
                fp_mac_30 #(.N(N)) mac_unit_30 ( 
                    .clk(clk_30), 
                    .reset(reset_30), 
                    .pushin(1'b1), 
                    .A(A_reg_30[row_30][col_30]), 
                    .B(B_reg_30[row_30][col_30]), 
                    .C((col_30 == 0) ? 0 : Z_internal_30[row_30][col_30-1]), 
                    .Z(Z_internal_30[row_30][col_30]), 
                    .pushout(pushout_wires_30[row_30 * 4 + col_30]) 
                ); 
            end 
        end 
    endgenerate 

    // Set output_valid_30 signal 
    always @(posedge clk_30 or posedge reset_30) begin 
        if (reset_30) begin 
            output_valid_30 <= 0; 
        end else begin 
            output_valid_30 <= pushout_wires_30[15]; 
        end 
    end 

endmodule 


