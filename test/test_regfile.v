`timescale 1ns / 1ps

module test_regfile();

reg clk = 1, rst = 0;
reg [1:0] op;
reg [3:0] sel_in_1, sel_in_2, sel_in_3, sel_out_1, sel_out_2, sel_out_3;
reg [63:0] data_in, in_1, in_2;
wire [63:0] data_out, out_1, out_2;

regfile r(clk, rst, op, sel_in_1, sel_in_2, sel_in_3, sel_out_1, sel_out_2, sel_out_3, data_in, data_out, in_1, in_2, out_1, out_2);

always #1 clk <= ~clk;

reg [63:0] in1[0:3], in2[0:3], in1_t[0:3], out1[0:3], out2[0:3];

initial
begin
/* Test data initialization */
in1[0] = {16'd13, 16'd9, 16'd5, 16'd1};
in1[1] = {16'd14, 16'd10, 16'd6, 16'd2};
in1[2] = {16'd15, 16'd11, 16'd7, 16'd3};
in1[3] = {16'd16, 16'd12, 16'd8, 16'd4};

in2[0] = {16'd20, 16'd19, 16'd18, 16'd17};
in2[1] = {16'd24, 16'd23, 16'd22, 16'd21};
in2[2] = {16'd28, 16'd27, 16'd26, 16'd25};
in2[3] = {16'd32, 16'd31, 16'd30, 16'd29};

in1_t[0] = {16'd4, 16'd3, 16'd2, 16'd1};
in1_t[1] = {16'd8, 16'd7, 16'd6, 16'd5};
in1_t[2] = {16'd12, 16'd11, 16'd10, 16'd9};
in1_t[3] = {16'd16, 16'd15, 16'd14, 16'd13};

/* Reset */
#8 rst = 1;
#4 rst = 0;
op = 0;  // No transpose
sel_in_1 = 1;
sel_in_3 = 2;
sel_out_1 = 1;
sel_out_2 = 2;
sel_out_3 = 1;

/* Data input */
in_1 = in1[0];
data_in = in2[0];

#2 in_1 = in1[1];
data_in = in2[1];

#2 in_1 = in1[2];
data_in = in2[2];

#2 in_1 = in1[3];
data_in = in2[3];

/* Data output test */
#2
sel_in_1 = 0;   // Make sure data are not over-written
sel_in_3 = 0;

out1[0] = data_out;
out2[0] = out_2;

#2 out1[1] = data_out;
out2[1] = out_2;

#2 out1[2] = data_out;
out2[2] = out_2;

#2 out1[3] = data_out;
out2[3] = out_2;

$display("[%s] reg_out, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {out1[0], out1[1], out1[2], out1[3]} === {in1[0], in1[1], in1[2], in1[3]} ? "PASS" : "FAIL",
    out1[0][15:0], out1[0][31:16], out1[0][47:32], out1[0][63:48], out1[1][15:0], out1[1][31:16], out1[1][47:32], out1[1][63:48],
    out1[2][15:0], out1[2][31:16], out1[2][47:32], out1[2][63:48], out1[3][15:0], out1[3][31:16], out1[3][47:32], out1[3][63:48],
    in1[0][15:0], in1[0][31:16], in1[0][47:32], in1[0][63:48], in1[1][15:0], in1[1][31:16], in1[1][47:32], in1[1][63:48],
    in1[2][15:0], in1[2][31:16], in1[2][47:32], in1[2][63:48], in1[3][15:0], in1[3][31:16], in1[3][47:32], in1[3][63:48]);

$display("[%s] data_out, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {out2[0], out2[1], out2[2], out2[3]} === {in2[0], in2[1], in2[2], in2[3]} ? "PASS" : "FAIL",
    out2[0][15:0], out2[0][31:16], out2[0][47:32], out2[0][63:48], out2[1][15:0], out2[1][31:16], out2[1][47:32], out2[1][63:48],
    out2[2][15:0], out2[2][31:16], out2[2][47:32], out2[2][63:48], out2[3][15:0], out2[3][31:16], out2[3][47:32], out2[3][63:48],
    in2[0][15:0], in2[0][31:16], in2[0][47:32], in2[0][63:48], in2[1][15:0], in2[1][31:16], in2[1][47:32], in2[1][63:48],
    in2[2][15:0], in2[2][31:16], in2[2][47:32], in2[2][63:48], in2[3][15:0], in2[3][31:16], in2[3][47:32], in2[3][63:48]);

/* Transpose test */
op = 2'b11;

#2 out1[0] = out_1;
#2 out1[1] = out_1;
#2 out1[2] = out_1;
#2 out1[3] = out_1;

$display("[%s] transpose, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {out1[0], out1[1], out1[2], out1[3]} === {in1_t[0], in1_t[1], in1_t[2], in1_t[3]} ? "PASS" : "FAIL",
    out1[0][15:0], out1[0][31:16], out1[0][47:32], out1[0][63:48], out1[1][15:0], out1[1][31:16], out1[1][47:32], out1[1][63:48],
    out1[2][15:0], out1[2][31:16], out1[2][47:32], out1[2][63:48], out1[3][15:0], out1[3][31:16], out1[3][47:32], out1[3][63:48],
    in1_t[0][15:0], in1_t[0][31:16], in1_t[0][47:32], in1_t[0][63:48], in1_t[1][15:0], in1_t[1][31:16], in1_t[1][47:32], in1_t[1][63:48],
    in1_t[2][15:0], in1_t[2][31:16], in1_t[2][47:32], in1_t[2][63:48], in1_t[3][15:0], in1_t[3][31:16], in1_t[3][47:32], in1_t[3][63:48]);

$finish;
end

endmodule
