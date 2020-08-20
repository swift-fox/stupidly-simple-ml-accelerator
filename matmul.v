module matmul #(
    parameter N = 4,
    parameter L = 16,
    localparam W = N * L    // Bit width of data ports
) (
    input clk, rst,
    input [1:0] op,
    input [W - 1:0] a, b,
    output [W - 1:0] c
);

wire calc, clr, _rst;
wire [L - 1:0] a0, a1, a2, a3, b0, b1, b2, b3;
wire [W - 1:0] _c[0: N - 1];
reg [1:0] tick = 0;

assign {calc, clr} = op;
assign {a3, a2, a1, a0, b3, b2, b1, b0} = calc ? {a, b} : 0;
assign _rst = rst || clr;

always @ (posedge clk) tick <= _rst ? 3 : tick + 1;
assign c = _c[tick];

systolic_unit u00(clk, _rst, a0, b0, _c[0][15:0]);
systolic_unit u01(clk, _rst, a0, b1, _c[0][31:16]);
systolic_unit u02(clk, _rst, a0, b2, _c[0][47:32]);
systolic_unit u03(clk, _rst, a0, b3, _c[0][63:48]);

systolic_unit u10(clk, _rst, a1, b0, _c[1][15:0]);
systolic_unit u11(clk, _rst, a1, b1, _c[1][31:16]);
systolic_unit u12(clk, _rst, a1, b2, _c[1][47:32]);
systolic_unit u13(clk, _rst, a1, b3, _c[1][63:48]);

systolic_unit u20(clk, _rst, a2, b0, _c[2][15:0]);
systolic_unit u21(clk, _rst, a2, b1, _c[2][31:16]);
systolic_unit u22(clk, _rst, a2, b2, _c[2][47:32]);
systolic_unit u23(clk, _rst, a2, b3, _c[2][63:48]);

systolic_unit u30(clk, _rst, a3, b0, _c[3][15:0]);
systolic_unit u31(clk, _rst, a3, b1, _c[3][31:16]);
systolic_unit u32(clk, _rst, a3, b2, _c[3][47:32]);
systolic_unit u33(clk, _rst, a3, b3, _c[3][63:48]);

endmodule

module systolic_unit(
    input clk, rst,
    input [15:0] a, b,
    output reg [15:0] c = 0
);

mac m(a, b, c);
always @(posedge clk) c <= rst ? 0 : m.y;

endmodule

module mac(
    input signed [15:0] a,
    input signed [15:0] b,
    input signed [15:0] c,
    output signed [15:0] y
);

assign y = a * b + c;

endmodule
