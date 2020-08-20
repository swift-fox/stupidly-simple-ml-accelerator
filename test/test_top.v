`timescale 1ns / 1ps

module test_top();

reg clk = 1, rst = 0;
reg [31:0] inst, io_inst;
reg [63:0] data_in;
wire [63:0] data_out;

top dut(clk, rst, inst, io_inst, data_in, data_out);

always #1 clk <= ~clk;

reg [63:0] in1[0:3], in2[0:3], out[0:3];

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

/* Reset */
#8 rst = 1;
#4 rst = 0;

/* IO instruction test */
io_inst = {8'h0, 4'h1, 4'h0, 16'h0};    // Write to r1
data_in = in1[0];

#2 data_in = in1[1];
#2 data_in = in1[2];
#2 data_in = in1[3];

#2 io_inst = {8'h0, 4'h0, 4'h1, 16'h0};    // Read r1
out[0] = data_out;
#2 out[1] = data_out;
#2 out[2] = data_out;
#2 out[3] = data_out;

$display("[%s] reg_io, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {out[0], out[1], out[2], out[3]} === {in1[0], in1[1], in1[2], in1[3]} ? "PASS" : "FAIL",
    out[0][15:0], out[0][31:16], out[0][47:32], out[0][63:48], out[1][15:0], out[1][31:16], out[1][47:32], out[1][63:48],
    out[2][15:0], out[2][31:16], out[2][47:32], out[2][63:48], out[3][15:0], out[3][31:16], out[3][47:32], out[3][63:48],
    in1[0][15:0], in1[0][31:16], in1[0][47:32], in1[0][63:48], in1[1][15:0], in1[1][31:16], in1[1][47:32], in1[1][63:48],
    in1[2][15:0], in1[2][31:16], in1[2][47:32], in1[2][63:48], in1[3][15:0], in1[3][31:16], in1[3][47:32], in1[3][63:48]);

$finish;
end

endmodule
