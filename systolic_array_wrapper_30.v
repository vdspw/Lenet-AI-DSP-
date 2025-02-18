`timescale 1ns / 1ps

module systolic_array_wrapper #(
    parameter N = 16,        // Data bit width
    parameter SIZE = 4       // Systolic array size
)(
    input clk,
    input reset,
    input [N*SIZE*SIZE-1:0] A_30,  // Input matrix A (flattened)
    input [N*SIZE*SIZE-1:0] B_30,  // Input matrix B (flattened)
    output reg [N*SIZE*SIZE-1:0] Z_30,  // Output matrix Z (flattened)
    output reg output_valid_30
);
    // Declare genvar and integer for loops
    genvar i_30, j_30;
    integer k_30, l_30;

    // Internal arrays for systolic array connections
    wire [N-1:0] A_array_30 [0:SIZE-1][0:SIZE-1];
    wire [N-1:0] B_array_30 [0:SIZE-1][0:SIZE-1];
    wire [N-1:0] Z_array_30 [0:SIZE-1][0:SIZE-1];
    wire pushout_array_30 [0:SIZE*SIZE-1];

    // Unflatten A and B
    generate
        for (i_30 = 0; i_30 < SIZE; i_30 = i_30 + 1) begin : gen_row_30
            for (j_30 = 0; j_30 < SIZE; j_30 = j_30 + 1) begin : gen_col_30
                assign A_array_30[i_30][j_30] = A_30[((i_30*SIZE + j_30 + 1)*N-1) -: N];
                assign B_array_30[i_30][j_30] = B_30[((i_30*SIZE + j_30 + 1)*N-1) -: N];
            end
        end
    endgenerate

    // Instantiate the systolic array
    systolic_array_4x4 #(.N(N)) systolic_array_inst (
        .clk(clk),
        .reset(reset),
        .A_00(A_array_30[0][0]), .A_01(A_array_30[0][1]), .A_02(A_array_30[0][2]), .A_03(A_array_30[0][3]),
        .A_10(A_array_30[1][0]), .A_11(A_array_30[1][1]), .A_12(A_array_30[1][2]), .A_13(A_array_30[1][3]),
        .A_20(A_array_30[2][0]), .A_21(A_array_30[2][1]), .A_22(A_array_30[2][2]), .A_23(A_array_30[2][3]),
        .A_30(A_array_30[3][0]), .A_31(A_array_30[3][1]), .A_32(A_array_30[3][2]), .A_33(A_array_30[3][3]),
        .B_00(B_array_30[0][0]), .B_01(B_array_30[0][1]), .B_02(B_array_30[0][2]), .B_03(B_array_30[0][3]),
        .B_10(B_array_30[1][0]), .B_11(B_array_30[1][1]), .B_12(B_array_30[1][2]), .B_13(B_array_30[1][3]),
        .B_20(B_array_30[2][0]), .B_21(B_array_30[2][1]), .B_22(B_array_30[2][2]), .B_23(B_array_30[2][3]),
        .B_30(B_array_30[3][0]), .B_31(B_array_30[3][1]), .B_32(B_array_30[3][2]), .B_33(B_array_30[3][3]),
        .Z_00(Z_array_30[0][0]), .Z_01(Z_array_30[0][1]), .Z_02(Z_array_30[0][2]), .Z_03(Z_array_30[0][3]),
        .Z_10(Z_array_30[1][0]), .Z_11(Z_array_30[1][1]), .Z_12(Z_array_30[1][2]), .Z_13(Z_array_30[1][3]),
        .Z_20(Z_array_30[2][0]), .Z_21(Z_array_30[2][1]), .Z_22(Z_array_30[2][2]), .Z_23(Z_array_30[2][3]),
        .Z_30(Z_array_30[3][0]), .Z_31(Z_array_30[3][1]), .Z_32(Z_array_30[3][2]), .Z_33(Z_array_30[3][3]),
        .output_valid(pushout_array_30[15])
    );

    // Flatten Z output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Z_30 <= 0;
            output_valid_30 <= 1'b0;
        end else begin
            for (k_30 = 0; k_30 < SIZE; k_30 = k_30 + 1) begin
                for (l_30 = 0; l_30 < SIZE; l_30 = l_30 + 1) begin
                    Z_30[((k_30*SIZE + l_30 + 1)*N-1) -: N] <= Z_array_30[k_30][l_30];
                end
            end
            output_valid_30 <= pushout_array_30[15];
        end
    end
endmodule
