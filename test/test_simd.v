`timescale 1ns / 1ps

module test_simd();

reg [1:0] op;
reg [63:0] in1 = {16'd1, 16'd2, 16'd3, 16'd4};
reg [63:0] in2 = {16'd5, 16'd6, 16'd7, 16'd8};
reg [15:0] constant = 2;
wire [63:0] sv_out, sc_out;

simd_vector sv(op, in1, in2, sv_out);
simd_scalar sc(op, in1, constant, sc_out);

reg [63:0] sv_out_nop = {16'd0, 16'd0, 16'd0, 16'd0};
reg [63:0] sc_out_nop = {16'd1, 16'd2, 16'd3, 16'd4};

reg [63:0] sv_out_add = {16'd6, 16'd8, 16'd10, 16'd12};
reg [63:0] sc_out_thr = {16'd2, 16'd2, 16'd3, 16'd4};

reg [63:0] sv_out_sub = {-16'd4, -16'd4, -16'd4, -16'd4};
reg [63:0] sc_out_cmp = {16'd0, 16'd0, 16'd1, 16'd1};

reg [63:0] sv_out_mul = {16'd5, 16'd12, 16'd21, 16'd32};
reg [63:0] sc_out_mul = {16'd2, 16'd4, 16'd6, 16'd8};

initial
begin
op = 0;  // nop
#1
$display("[%s] nop, sv_out = [%d %d %d %d], expect [%d %d %d %d]",
    sv_out === sv_out_nop ? "PASS" : "FAIL", sv_out[63:48], sv_out[47:32], sv_out[31:16], sv_out[15:0],
    sv_out_nop[63:48], sv_out_nop[47:32], sv_out_nop[31:16], sv_out_nop[15:0]);

$display("[%s] nop, sc_out = [%d %d %d %d], expect [%d %d %d %d]",
    sc_out === sc_out_nop ? "PASS" : "FAIL", sc_out[63:48], sc_out[47:32], sc_out[31:16], sc_out[15:0],
    sc_out_nop[63:48], sc_out_nop[47:32], sc_out_nop[31:16], sc_out_nop[15:0]);

op = 1;  // sv: add, sc: threshold
#1
$display("[%s] add, sv_out = [%d %d %d %d], expect [%d %d %d %d]",
    sv_out === sv_out_add ? "PASS" : "FAIL", sv_out[63:48], sv_out[47:32], sv_out[31:16], sv_out[15:0],
    sv_out_add[63:48], sv_out_add[47:32], sv_out_add[31:16], sv_out_add[15:0]);

$display("[%s] thr, sc_out = [%d %d %d %d], expect [%d %d %d %d]",
    sc_out === sc_out_thr ? "PASS" : "FAIL", sc_out[63:48], sc_out[47:32], sc_out[31:16], sc_out[15:0],
    sc_out_thr[63:48], sc_out_thr[47:32], sc_out_thr[31:16], sc_out_thr[15:0]);

op = 2;  // sv: sub, sc: logical compare
#1
$display("[%s] sub, sv_out = [%d %d %d %d], expect [%d %d %d %d]",
    sv_out === sv_out_sub ? "PASS" : "FAIL", sv_out[63:48], sv_out[47:32], sv_out[31:16], sv_out[15:0],
    sv_out_sub[63:48], sv_out_sub[47:32], sv_out_sub[31:16], sv_out_sub[15:0]);

$display("[%s] cmp, sc_out = [%d %d %d %d], expect [%d %d %d %d]",
    sc_out === sc_out_cmp ? "PASS" : "FAIL", sc_out[63:48], sc_out[47:32], sc_out[31:16], sc_out[15:0],
    sc_out_cmp[63:48], sc_out_cmp[47:32], sc_out_cmp[31:16], sc_out_cmp[15:0]);

op = 3;  // sv: mul, sc: mul
#1
$display("[%s] mul, sv_out = [%d %d %d %d], expect [%d %d %d %d]",
    sv_out === sv_out_mul ? "PASS" : "FAIL", sv_out[63:48], sv_out[47:32], sv_out[31:16], sv_out[15:0],
    sv_out_mul[63:48], sv_out_mul[47:32], sv_out_mul[31:16], sv_out_mul[15:0]);

$display("[%s] mul, sc_out = [%d %d %d %d], expect [%d %d %d %d]",
    sc_out === sc_out_mul ? "PASS" : "FAIL", sc_out[63:48], sc_out[47:32], sc_out[31:16], sc_out[15:0],
    sc_out_mul[63:48], sc_out_mul[47:32], sc_out_mul[31:16], sc_out_mul[15:0]);

$finish;
end

endmodule
