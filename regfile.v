module regfile #(
    parameter N = 4,
    parameter L = 16,
    parameter N_REGS = 16,  // Must be power of 2
    localparam W = N * L    // Bit width of data ports and internal storage
) (
    input clk, rst,
    input [1:0] op,
    input [3:0] sel_in_1, sel_in_2, sel_in_3, sel_out_1, sel_out_2, sel_out_3,
    input [W - 1:0] in_3,
    output [W - 1:0] out_3,
    input [W - 1:0] in_1, in_2,
    output [W - 1:0] out_1, out_2
);

reg [L - 1:0] regs [0:N_REGS - 1][0:N - 1][0:N - 1];
reg [1:0] tick = 0;

always @(posedge clk)
begin
    tick <= rst ? 0 : tick + 1;
    {regs[sel_in_1][tick][3], regs[sel_in_1][tick][2], regs[sel_in_1][tick][1], regs[sel_in_1][tick][0]} <= in_1;
    {regs[sel_in_2][tick][3], regs[sel_in_2][tick][2], regs[sel_in_2][tick][1], regs[sel_in_2][tick][0]} <= in_2;
    {regs[sel_in_3][tick][3], regs[sel_in_3][tick][2], regs[sel_in_3][tick][1], regs[sel_in_3][tick][0]} <= in_3;
end

assign out_1 = op[1] ? {regs[sel_out_1][3][tick], regs[sel_out_1][2][tick], regs[sel_out_1][1][tick], regs[sel_out_1][0][tick]} :
    {regs[sel_out_1][tick][3], regs[sel_out_1][tick][2], regs[sel_out_1][tick][1], regs[sel_out_1][tick][0]};
assign out_2 = op[0] ? {regs[sel_out_2][3][tick], regs[sel_out_2][2][tick], regs[sel_out_2][1][tick], regs[sel_out_2][0][tick]} :
    {regs[sel_out_2][tick][3], regs[sel_out_2][tick][2], regs[sel_out_2][tick][1], regs[sel_out_2][tick][0]};
assign out_3 = {regs[sel_out_3][tick][3], regs[sel_out_3][tick][2], regs[sel_out_3][tick][1], regs[sel_out_3][tick][0]};

endmodule
