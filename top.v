module top(
    input clk,
    input rst,
    input [31:0] inst,
    input [31:0] io_inst,
    input [63:0] data_in,
    output [63:0] data_out
);

wire [1:0] op_mm, op_sv, op_ss, op_t;
wire [3:0] sel_in_1, sel_in_2, sel_out_1, sel_out_2;
wire [7:0] reserved_1;

wire [7:0] reserved_2;
wire [3:0] sel_in_3, sel_out_3;
wire [15:0] constant;

assign {op_mm, op_sv, op_ss, op_t, sel_in_1, sel_in_2, sel_out_1, sel_out_2, reserved_1} = inst;
assign {reserved_2, sel_in_3, sel_out_3, constant} = io_inst;

regfile r(clk, rst, op_t, sel_in_1, sel_in_2, sel_in_3, sel_out_1, sel_out_2, sel_out_3, data_in, data_out);
matmul mm(clk, rst, op_mm, r.out_1, r.out_2);
simd_vector sv(op_sv, r.out_1, r.out_2);
simd_scalar ss(op_ss, r.in_1, constant, r.in_2);
mux2 m(op_mm[1] || op_sv, r.in_1, mm.c, sv.c);

endmodule

module mux2(
    input sel,
    output [63:0] c,
    input [63:0] a, b
);

assign c = sel ? b : a;

endmodule
