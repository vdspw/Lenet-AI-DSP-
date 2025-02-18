`timescale 1ns / 1ps

module lenet_forward #(parameter N = 16) (
    input wire clk,
    input wire reset,
    input wire [N*32*32-1:0] input_image_30,  // Flattened 32x32 input image
    input wire [N*400-1:0] fc1_weights_30,    // Weights for fully connected layer 1
    input wire [N*120-1:0] fc2_weights_30,    // Weights for fully connected layer 2
    input wire [N*84-1:0] fc3_weights_30,     // Weights for fully connected layer 3
    output reg [3:0] predicted_class_30,      // Predicted class (0-9)
    output reg output_valid_30                // Valid signal for the output
);

    // Intermediate signals
    wire [N*28*28-1:0] conv1_out_30;    // Output of the first convolutional layer
    wire [N*14*14-1:0] pool1_out_30;    // Output of the first pooling layer
    wire [N*10*10-1:0] conv2_out_30;    // Output of the second convolutional layer
    wire [N*5*5-1:0] pool2_out_30;      // Output of the second pooling layer
    wire [N*120-1:0] fc1_out_30;        // Output of the first fully connected layer
    wire [N*84-1:0] fc2_out_30;         // Output of the second fully connected layer
    wire [N*10-1:0] fc3_out_30;         // Output of the third fully connected layer (logits)
    wire fc_valid_30;                   // Valid signal from the final fully connected layer

    // -------------------
    // Convolutional Layer 1
    // -------------------
    systolic_array_wrapper #(.N(N), .SIZE(4)) conv1 (
        .clk(clk),
        .reset(reset),
        .A(input_image_30),      // Input image
        .B(conv1_kernels_30),    // Convolution kernels for layer 1
        .Z(conv1_out_30),        // Convolution output
        .output_valid()          // Output valid signal
    );

    // -------------------
    // ReLU Activation 1
    // -------------------
    relu #(.N(N)) relu1 (
        .in(conv1_out_30),
        .out(pool1_out_30)  // ReLU output fed directly to pooling
    );

    // -------------------
    // Max Pooling 1 (Manual Instantiation)
    // -------------------
    maxpool2x2 #(.N(N)) pool1_00 (
        .input_block({
            pool1_out_30[111:96], // in_00
            pool1_out_30[95:80],  // in_01
            pool1_out_30[79:64],  // in_10
            pool1_out_30[63:48]   // in_11
        }),
        .output_value(pool1_out_30[15:0])
    );

    // -------------------
    // Convolutional Layer 2
    // -------------------
    systolic_array_wrapper #(.N(N), .SIZE(4)) conv2 (
        .clk(clk),
        .reset(reset),
        .A(pool1_out_30),        // Output of pooling layer 1
        .B(conv2_kernels_30),    // Convolution kernels for layer 2
        .Z(conv2_out_30),        // Convolution output
        .output_valid()          // Output valid signal
    );

    // -------------------
    // ReLU Activation 2
    // -------------------
    relu #(.N(N)) relu2 (
        .in(conv2_out_30),
        .out(pool2_out_30)  // ReLU output fed directly to pooling
    );

    // -------------------
    // Max Pooling 2 (Manual Instantiation)
    // -------------------
    maxpool2x2 #(.N(N)) pool2_00 (
        .input_block({
            pool2_out_30[79:64], // in_00
            pool2_out_30[63:48], // in_01
            pool2_out_30[47:32], // in_10
            pool2_out_30[31:16]  // in_11
        }),
        .output_value(pool2_out_30[15:0])
    );

    // -------------------------
    // Fully Connected Layers
    // -------------------------
    systolic_array_wrapper #(.N(N), .SIZE(4)) fc1 (
        .clk(clk),
        .reset(reset),
        .A(pool2_out_30),        // Flattened input from pooling layer 2
        .B(fc1_weights_30),      // Weights for FC1
        .Z(fc1_out_30),          // FC1 output
        .output_valid()          // Output valid signal
    );

    systolic_array_wrapper #(.N(N), .SIZE(4)) fc2 (
        .clk(clk),
        .reset(reset),
        .A(fc1_out_30),          // Input from FC1
        .B(fc2_weights_30),      // Weights for FC2
        .Z(fc2_out_30),          // FC2 output
        .output_valid()          // Output valid signal
    );

    systolic_array_wrapper #(.N(N), .SIZE(4)) fc3 (
        .clk(clk),
        .reset(reset),
        .A(fc2_out_30),          // Input from FC2
        .B(fc3_weights_30),      // Weights for FC3
        .Z(fc3_out_30),          // FC3 output
        .output_valid(fc_valid_30)  // Output valid signal
    );

    // -------------------
    // Prediction Logic
    // -------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            predicted_class_30 <= 4'd0;
            output_valid_30 <= 1'b0;
        end else if (fc_valid_30) begin
            predicted_class_30 <= argmax(fc3_out_30); // Select the class with the highest score
            output_valid_30 <= 1'b1;
        end
    end

    // Function to compute argmax
    function [3:0] argmax;
        input [N*10-1:0] logits_30;
        integer k_30;
        reg [N-1:0] max_val_30;
        begin
            max_val_30 = logits_30[N-1:0];
            argmax = 4'd0;
            for (k_30 = 1; k_30 < 10; k_30 = k_30 + 1) begin
                if (logits_30[k_30*N +: N] > max_val_30) begin
                    max_val_30 = logits_30[k_30*N +: N];
                    argmax = k_30[3:0];
                end
            end
        end
    endfunction

endmodule
