module relu #(parameter N = 16) (
    input wire [N-1:0] in_30,
    output wire [N-1:0] out_30
);
    assign out_30 = (in_30[N-1] == 1'b1) ? {N{1'b0}} : in_30; // Zero for negative inputs
endmodule
