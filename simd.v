module simd_vector #(
    parameter N = 4,
    parameter L = 16,
    localparam W = N * L    // Bit width of data ports
) (
    input [1:0] op,
    input [W - 1:0] a, b,
    output reg [W - 1:0] c
);

`define nop 2'b00
`define add 2'b01
`define sub 2'b10
`define mul 2'b11   // Element-wise mul

always @(*)
begin
    case (op)
        `nop: c = 0;
        `add: c = {a[63:48] + b[63:48], a[47:32] + b[47:32], a[31:16] + b[31:16], a[15:0] + b[15:0]};
        `sub: c = {a[63:48] - b[63:48], a[47:32] - b[47:32], a[31:16] - b[31:16], a[15:0] - b[15:0]};
        `mul: c = {a[63:48] * b[63:48], a[47:32] * b[47:32], a[31:16] * b[31:16], a[15:0] * b[15:0]};
    endcase
end

endmodule

module simd_scalar #(
    parameter N = 4,
    parameter L = 16,
    localparam W = N * L    // Bit width of data ports
) (
    input [1:0] op,
    input [W - 1:0] a,
    input [L - 1:0] b,
    output reg [W - 1:0] c
);

`define nop     2'b00
`define thr     2'b01   // Threshold
`define cmp     2'b10   // Logical compare
`define mul     2'b11   // Scalar mul

always @(*)
begin
    case (op)
        `nop: c = a;
        `thr: c = {a[63:48] > b ? a[63:48] : b, a[47:32] > b ? a[47:32] : b, a[31:16] > b ? a[31:16] : b, a[15:0] > b ? a[15:0] : b};
        `cmp: c = {{15'h0, a[63:48] > b}, {15'h0, a[47:32] > b}, {15'h0, a[31:16] > b}, {15'h0, a[15:0] > b}};
        `mul: c = {a[63:48] * b, a[47:32] * b, a[31:16] * b, a[15:0] * b};
    endcase
end

endmodule
