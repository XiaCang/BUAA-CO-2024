module nextpc(
    input [31:0] pc,
    input [15:0] imm16,
    input [25:0] imm26,
    input [31:0] imm32,
    input branch,
    input jump,
    input jr,
    input zero,
    output [31:0] next_pc
);
wire [31:0] _pc_plus_4;

wire [31:0] _extended_imm16;
wire [31:0] _branch_target;

wire [31:0] _extended_imm26;
wire [31:0] _jump_target;

wire [31:0] _jr_target;

wire [31:0] _mux1;
wire [31:0] _mux2;
wire [31:0] _mux3;

assign _pc_plus_4 = pc + 4;
assign _extended_imm16 = {{14{imm16[15]}}, imm16, 2'b00};
assign _branch_target = _extended_imm16 + _pc_plus_4; 

assign _extended_imm26 = {pc[31:28], imm26, 2'b00};
assign _jump_target = _extended_imm26;

assign _jr_target = imm32;
assign _mux1 = (branch && zero) ? _branch_target : _pc_plus_4;
assign _mux2 = (jump) ? _jump_target : _mux1;
assign _mux3 = (jr) ? _jr_target : _mux2;

assign next_pc = _mux3;


endmodule