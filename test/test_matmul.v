`timescale 1ns / 1ps

module test_matmul();

reg clk = 1, rst = 0;
reg [1:0] op;
reg [63:0] a, b;
wire [63:0] c;

matmul mm(clk, rst, op, a, b, c);

reg [63:0] in1[0:3], in2[0:3], mm_out[0:3], mm_rst[0:3], mm_mm[0:3];

always #1 clk <= ~clk;

initial
begin
/* Array initialization */
in1[0] = {16'd13, 16'd9, 16'd5, 16'd1};
in1[1] = {16'd14, 16'd10, 16'd6, 16'd2};
in1[2] = {16'd15, 16'd11, 16'd7, 16'd3};
in1[3] = {16'd16, 16'd12, 16'd8, 16'd4};

in2[0] = {16'd20, 16'd19, 16'd18, 16'd17};
in2[1] = {16'd24, 16'd23, 16'd22, 16'd21};
in2[2] = {16'd28, 16'd27, 16'd26, 16'd25};
in2[3] = {16'd32, 16'd31, 16'd30, 16'd29};

{mm_rst[0], mm_rst[1], mm_rst[2], mm_rst[3]} = 256'b0;

mm_mm[0] = {16'd280, 16'd270, 16'd260, 16'd250};
mm_mm[1] = {16'd696, 16'd670, 16'd644, 16'd618};
mm_mm[2] = {16'd1112, 16'd1070, 16'd1028, 16'd986};
mm_mm[3] = {16'd1528, 16'd1470, 16'd1412, 16'd1354};

/* Reset test */
op = 2'b10; // Do caculation
{a, b} = 128'b0;

#8 rst = 1;
#4 rst = 0;

#2 mm_out[0] = c;
#2 mm_out[1] = c;
#2 mm_out[2] = c;
#2 mm_out[3] = c;

$display("[%s] reset, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {mm_out[0], mm_out[1], mm_out[2], mm_out[3]} === {mm_rst[0], mm_rst[1], mm_rst[2], mm_rst[3]} ? "PASS" : "FAIL",
    mm_out[0][15:0], mm_out[0][31:16], mm_out[0][47:32], mm_out[0][63:48], mm_out[1][15:0], mm_out[1][31:16], mm_out[1][47:32], mm_out[1][63:48],
    mm_out[2][15:0], mm_out[2][31:16], mm_out[2][47:32], mm_out[2][63:48], mm_out[3][15:0], mm_out[3][31:16], mm_out[3][47:32], mm_out[3][63:48],
    mm_rst[0][15:0], mm_rst[0][31:16], mm_rst[0][47:32], mm_rst[0][63:48], mm_rst[1][15:0], mm_rst[1][31:16], mm_rst[1][47:32], mm_rst[1][63:48],
    mm_rst[2][15:0], mm_rst[2][31:16], mm_rst[2][47:32], mm_rst[2][63:48], mm_rst[3][15:0], mm_rst[3][31:16], mm_rst[3][47:32], mm_rst[3][63:48]);

/* Matmul calculation test */
rst = 0;
op = 2'b10; // Do caculation

{a, b} = {in1[0], in2[0]};
#2 {a, b} = {in1[1], in2[1]};
#2 {a, b} = {in1[2], in2[2]};
#2 {a, b} = {in1[3], in2[3]};

#2 op = 2'b00; // nop, output result

#2 mm_out[0] = c;
#2 mm_out[1] = c;
#2 mm_out[2] = c;
#2 mm_out[3] = c;

$display("[%s] matmul, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {mm_out[0], mm_out[1], mm_out[2], mm_out[3]} === {mm_mm[0], mm_mm[1], mm_mm[2], mm_mm[3]} ? "PASS" : "FAIL",
    mm_out[0][15:0], mm_out[0][31:16], mm_out[0][47:32], mm_out[0][63:48], mm_out[1][15:0], mm_out[1][31:16], mm_out[1][47:32], mm_out[1][63:48],
    mm_out[2][15:0], mm_out[2][31:16], mm_out[2][47:32], mm_out[2][63:48], mm_out[3][15:0], mm_out[3][31:16], mm_out[3][47:32], mm_out[3][63:48],
    mm_mm[0][15:0], mm_mm[0][31:16], mm_mm[0][47:32], mm_mm[0][63:48], mm_mm[1][15:0], mm_mm[1][31:16], mm_mm[1][47:32], mm_mm[1][63:48],
    mm_mm[2][15:0], mm_mm[2][31:16], mm_mm[2][47:32], mm_mm[2][63:48], mm_mm[3][15:0], mm_mm[3][31:16], mm_mm[3][47:32], mm_mm[3][63:48]);

/* Clear test */
op = 2'b01; // Clear

#8 op = 2'b10; // Do caculation

{a, b} = {in1[0], in2[0]};
#2 {a, b} = {in1[1], in2[1]};
#2 {a, b} = {in1[2], in2[2]};
#2 {a, b} = {in1[3], in2[3]};

#2 op = 2'b00; // nop, output result

#2 mm_out[0] = c;
#2 mm_out[1] = c;
#2 mm_out[2] = c;
#2 mm_out[3] = c;

$display("[%s] clear, out = [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]], expect [[%d %d %d %d], [%d %d %d %d], [%d %d %d %d], [%d %d %d %d]]",
    {mm_out[0], mm_out[1], mm_out[2], mm_out[3]} === {mm_mm[0], mm_mm[1], mm_mm[2], mm_mm[3]} ? "PASS" : "FAIL",
    mm_out[0][15:0], mm_out[0][31:16], mm_out[0][47:32], mm_out[0][63:48], mm_out[1][15:0], mm_out[1][31:16], mm_out[1][47:32], mm_out[1][63:48],
    mm_out[2][15:0], mm_out[2][31:16], mm_out[2][47:32], mm_out[2][63:48], mm_out[3][15:0], mm_out[3][31:16], mm_out[3][47:32], mm_out[3][63:48],
    mm_mm[0][15:0], mm_mm[0][31:16], mm_mm[0][47:32], mm_mm[0][63:48], mm_mm[1][15:0], mm_mm[1][31:16], mm_mm[1][47:32], mm_mm[1][63:48],
    mm_mm[2][15:0], mm_mm[2][31:16], mm_mm[2][47:32], mm_mm[2][63:48], mm_mm[3][15:0], mm_mm[3][31:16], mm_mm[3][47:32], mm_mm[3][63:48]);

#2 $finish;
end

endmodule
