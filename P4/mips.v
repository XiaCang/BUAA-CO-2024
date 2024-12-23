module mips(
    input clk,
    input reset
);

wire [31:0] s_instr;
wire [2:0] s_regDst;
wire s_aluSrc;
wire s_memToReg;
wire s_regWrite;
wire s_memWrite;
wire s_branch;
wire s_jump;
wire s_jr;
wire s_zero;
wire [2:0] s_extOp;
wire [2:0] s_aluOp;

wire [4:0] r_rs;
wire [4:0] r_rt;
wire [4:0] r_rd;
wire [15:0] r_imm16;
wire [25:0] r_imm26;

wire [4:0] t_regAddr;

wire [31:0] t_regData;
wire [31:0] t_rdata1;
wire [31:0] t_rdata2;
wire [31:0] _pc;
wire [31:0] _next_pc;
wire [31:0] _extended_imm16;
wire [31:0] _alu_B;
wire [31:0] _alu_res;
wire [31:0] _mem_res;

regmux m_regmux(
    .rt(r_rt),
    .rd(r_rd),
    .regDst(s_regDst),
    .out(t_regAddr)
);

grf m_grf(
    .clk(clk),
    .reset(reset),
    .raddr1(r_rs),
    .raddr2(r_rt),
    .waddr(t_regAddr),
    .wdata(t_regData),
    .wenable(s_regWrite),
    .PC(_pc),
    .rdata1(t_rdata1),
    .rdata2(t_rdata2)
);

insextractor m_insextractor(
    .instr(s_instr),
    .rs(r_rs),
    .rt(r_rt),
    .rd(r_rd),
    .imm16(r_imm16),
    .imm26(r_imm26)
);

controller m_controller(
    .instr(s_instr),
    .regDst(s_regDst),
    .aluSrc(s_aluSrc),
    .memToReg(s_memToReg),
    .regWrite(s_regWrite),
    .memWrite(s_memWrite),
    .branch(s_branch),
    .jump(s_jump),
    .jr(s_jr),
    .extOp(s_extOp),
    .aluOp(s_aluOp)
);

im m_im(
    .clk(clk),
    .reset(reset),
    .next_pc(_next_pc),
    .instr(s_instr),
    .pc(_pc)
);

ext m_ext(
    .imm16(r_imm16),
    .extOp(s_extOp),
    .out32(_extended_imm16)
);


nextpc m_nextpc(
    .pc(_pc),
    .imm16(r_imm16),
    .imm26(r_imm26),
    .imm32(t_regData),
    .branch(s_branch),
    .jump(s_jump),
    .jr(s_jr),
    .zero(s_zero),
    .next_pc(_next_pc)
);


alusrcmux m_alusrcmux(
    .regnum(t_rdata2),
    .imm32(_extended_imm16),
    .aluSrc(s_aluSrc),
    .out(_alu_B)
);

alu m_alu(
    .A(t_rdata1),
    .B(_alu_B),
    .ALUOp(s_aluOp),
    .result(_alu_res),
    .zero(s_zero)
);

dm m_dm(
    .clk(clk),
    .reset(reset),
    .memWrite(s_memWrite),
    .pc(_pc),
    .addr(_alu_res),
    .writeData(t_rdata2),
    .readData(_mem_res)
);

regwritemux m_regwritemux(
    .aluout(_alu_res),
    .memout(_mem_res),
    .pc(_pc),
    .memToReg(s_memToReg),
    .jump(s_jump),
    .out(t_regData)
);

endmodule