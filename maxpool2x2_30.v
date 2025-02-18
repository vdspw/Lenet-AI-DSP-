module maxpool2x2 #(parameter N = 16) (
    input wire [N*4-1:0] input_block_30,  // Flattened 2x2 input block
    output wire [N-1:0] output_value_30  // Max pooled value
);
    // Unpack the 2x2 input block
    wire [N-1:0] in_00_30 = input_block_30[N*4-1:N*3];
    wire [N-1:0] in_01_30 = input_block_30[N*3-1:N*2];
    wire [N-1:0] in_10_30 = input_block_30[N*2-1:N];
    wire [N-1:0] in_11_30 = input_block_30[N-1:0];

    // Max pooling logic
    wire [N-1:0] max1_30 = (in_00_30 > in_01_30) ? in_00_30 : in_01_30;
    wire [N-1:0] max2_30 = (in_10_30 > in_11_30) ? in_10_30 : in_11_30;
    assign output_value_30 = (max1_30 > max2_30) ? max1_30 : max2_30;
endmodule
