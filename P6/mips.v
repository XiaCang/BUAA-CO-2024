module mips(
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
);

wire [31:0] instr_F;
wire [31:0] pc_F;
wire [31:0] nextpc_F;

wire [31:0] instr_D;
wire [31:0] pc_D;

wire [2:0] regDst_D;
wire [2:0] extOp_D;
wire [2:0] aluOp_D;
wire aluSrc_D;
wire memToReg_D;
wire regWrite_D;
wire memWrite_D;
wire branch_D;
wire jump_D;
wire jr_D;

wire [4:0] rs_D;
wire [4:0] rt_D;
wire [4:0] rd_D;
wire [15:0] imm16_D;
wire [25:0] imm26_D;
wire [31:0] imm32_D;

wire [4:0] regaddr_D;
wire [31:0] rdata1_D;
wire [31:0] rdata2_D;
wire [2:0] memByteen_D;
wire [1:0] cmpOp_D;
wire [2:0] mdop_D;
wire hlsel_D;
wire hlread_D;
wire hlwrite_D;
wire mdstart_D;

wire [4:0] rs_E;
wire [4:0] rt_E;
wire [31:0] pc_E;
wire [2:0] aluOp_E;
wire aluSrc_E;
wire memToReg_E;
wire regWrite_E;
wire memWrite_E;
wire branch_E;
wire jump_E;

wire [4:0] regaddr_E;
wire [31:0] rdata1_E;
wire [31:0] rdata2_E;
wire [31:0] imm32_E;
wire [31:0] alu_B_E;

wire zero_E;
wire [31:0] alu_res_E;
wire [31:0] data_E;

wire [2:0] memByteen_E;
wire [2:0] mdop_E;
wire hlsel_E;
wire hlread_E;
wire hlwrite_E;
wire mdstart_E;
wire busy_E;
wire [31:0] HI_E;
wire [31:0] LO_E;
wire [31:0] HLreg_E;


wire [31:0] pc_M;
wire [4:0] regaddr_M;
wire [31:0] alu_res_M;
wire memToReg_M;
wire regWrite_M;
wire memWrite_M;
wire branch_M;
wire jump_M;
wire [31:0] rdata2_M;
wire [31:0] mem_res_M;
wire [2:0] memByteen_M;


wire [31:0] pc_W;
wire [4:0] regaddr_W;
wire [31:0] alu_res_W;
wire memToReg_W;
wire regWrite_W;
wire [31:0] mem_res_W;
wire [31:0] regwdata_W;
wire jump_W;
wire zero;

wire [2:0] FowardA;
wire [2:0] FowardB;
wire [2:0] FowardAD;
wire [2:0] FowardBD;
wire stallPC;
wire stallF2D;
wire stallD2E;
wire stallE2M;
wire stallM2W;
wire clrD2E;
wire clrF2D;
wire clrE2M;
wire clearDelaySlot;
wire [31:0] rs_cmp;
wire [31:0] rt_cmp;

hazardcontrol u_hazardcontrol (
    .rsD(rs_D),
    .rtD(rt_D),
    .rsE(rs_E),
    .rtE(rt_E),
    .raE(regaddr_E),
    .raM(regaddr_M),
    .raW(regaddr_W),
    .branchD(branch_D),
    .jumpM(jump_M),
    .jumpD(jump_D),
    .jrD(jr_D),
    .zero(zero),
    .regWriteE(regWrite_E),
    .regWriteM(regWrite_M),
    .regWriteW(regWrite_W),
    .memToRegE(memToReg_E),
    .memToRegM(memToReg_M),
    .busyE(busy_E),
    .hlreadD(hlread_D),
    .mdstartE(mdstart_E),
    .hlwriteD(hlwrite_D),
    .mdstartD(mdstart_D),
    .clearDelaySlot(clearDelaySlot),

    .FowardA(FowardA),
    .FowardB(FowardB),
    .FowardAD(FowardAD),
    .FowardBD(FowardBD),
    .stallPC(stallPC),
    .stallF2D(stallF2D),
    .stallD2E(stallD2E),
    .stallE2M(stallE2M),
    .stallM2W(stallM2W),
    .ClrF2D(clrF2D),
    .ClrD2E(clrD2E),
    .ClrE2M(clrE2M)  
);

// ---------------------------- IF  -------------------------------- //

assign rs_cmp =(FowardAD == 3'b001) ? regwdata_W : 
            (FowardAD == 3'b010) ? alu_res_M :
            (FowardAD == 3'b011) ? 32'b0 : 
            (FowardAD == 3'b100) ? pc_M + 8 : rdata1_D;
assign rt_cmp =(FowardBD == 3'b001) ? regwdata_W : 
            (FowardBD == 3'b010) ? alu_res_M :
            (FowardBD == 3'b011) ? 32'b0 : 
            (FowardBD == 3'b100) ? pc_M + 8 : rdata2_D;
cmp u_cmp (
    .A(rs_cmp),
    .B(rt_cmp),
    .cmpOp(cmpOp_D),
    .zero(zero)
);

PC u_PC (
    .clk(clk),
    .reset(reset),
    .stall(stallPC),
    .next_pc(nextpc_F),
    .pc(pc_F)
);

assign i_inst_addr = pc_F;
//extract IM 
assign instr_F = i_inst_rdata;

nextpc u_nextpc (
    .pcF(pc_F),
    .pcD(pc_D),
    .imm16(imm16_D),
    .imm26(imm26_D),
    .imm32(rs_cmp),
    .branch(branch_D),
    .jump(jump_D),
    .jr(jr_D),
    .zero(zero),
    .next_pc(nextpc_F)
);

FDreg u_FDreg (
    .clk(clk),
    .reset(reset | clrF2D),
    .stall(stallF2D),
    .instr(instr_F),
    .pc(pc_F),
    .instr_out(instr_D),
    .pc_out(pc_D)
);


// ---------------------------- ID  -------------------------------- //


controller u_controller (
    .instr(instr_D),
    .regDst(regDst_D),
    .aluSrc(aluSrc_D),
    .memToReg(memToReg_D),
    .regWrite(regWrite_D),
    .memWrite(memWrite_D),
    .branch(branch_D),
    .jump(jump_D),
    .jr(jr_D),
    .extOp(extOp_D),
    .aluOp(aluOp_D),
    .memByteen(memByteen_D),
    .cmpOp(cmpOp_D),
    .mdop(mdop_D),
    .hlsel(hlsel_D),
    .hlread(hlread_D),
    .hlwrite(hlwrite_D),
    .mdstart(mdstart_D)
);

insextractor u_insextractor (
    .instr(instr_D),
    .rs(rs_D),
    .rt(rt_D),
    .rd(rd_D),
    .imm16(imm16_D),
    .imm26(imm26_D)
);

assign w_grf_we = regWrite_W & ~stallM2W;
assign w_grf_addr = regaddr_W;
assign w_grf_wdata = regwdata_W;
assign w_inst_addr = pc_W;

grf u_grf (
    .clk(clk),
    .reset(reset),
    .raddr1(rs_D),
    .raddr2(rt_D),
    .waddr(regaddr_W),
    .wdata(regwdata_W),
    .wenable(regWrite_W),
    .rdata1(rdata1_D),
    .rdata2(rdata2_D)
);

ext u_ext (
    .imm16(imm16_D),
    .extOp(extOp_D),
    .out32(imm32_D)
);

// regdestmux u_regdestmux (
//       .rt(rt_D),
//       .rd(rd_D),
//       .regDst(regDst_D),
//       .out(regaddr_D)
// );

assign regaddr_D = (regDst_D == 3'b000) ? rt_D : 
                    (regDst_D == 3'b001) ? rd_D : 
                    (regDst_D == 3'b010) ? 5'b11111 : 5'b00000;

//?rdata1是否需要为rs_cmp
DEreg u_DEReg (
    .clk(clk),
    .reset(reset | clrD2E),
    .pc(pc_D),
    .regaddr(regaddr_D),
    .rdata1(rdata1_D),
    .rdata2(rdata2_D),
    .imm32(imm32_D),
    .aluOp(aluOp_D),
    .aluSrc(aluSrc_D),
    .memToReg(memToReg_D),
    .regWrite(regWrite_D),
    .memWrite(memWrite_D),
    .branch(branch_D),
    .jump(jump_D),
    .rs(rs_D),
    .rt(rt_D),
    .stall(stallD2E),

    .memByteen(memByteen_D),

    .mdop(mdop_D),
    .hlsel(hlsel_D),
    .hlread(hlread_D),
    .hlwrite(hlwrite_D),
    .mdstart(mdstart_D),

    .memByteen_out(memByteen_E),

    .mdop_out(mdop_E),
    .hlsel_out(hlsel_E),
    .hlread_out(hlread_E),
    .hlwrite_out(hlwrite_E),
    .mdstart_out(mdstart_E),

    .pc_out(pc_E),
    .regaddr_out(regaddr_E),
    .rdata1_out(rdata1_E),
    .rdata2_out(rdata2_E),
    .imm32_out(imm32_E),
    .aluOp_out(aluOp_E),
    .aluSrc_out(aluSrc_E),
    .memToReg_out(memToReg_E),
    .regWrite_out(regWrite_E),
    .memWrite_out(memWrite_E),
    .branch_out(branch_E),
    .jump_out(jump_E),
    .rs_out(rs_E),
    .rt_out(rt_E)
);

// ---------------------------- EX  -------------------------------- //



wire [31:0] aluA;
wire [31:0] aluB;

assign aluA = 
            (FowardA == 3'b001 ) ? regwdata_W : 
              (FowardA == 3'b010 ) ? alu_res_M :
              (FowardA == 3'b011 ) ? 32'b0 :
              (FowardA == 3'b100 ) ? pc_E + 4 : rdata1_E;

assign aluB = (FowardB == 3'b001 ) ? regwdata_W : 
              (FowardB == 3'b010 ) ? alu_res_M : 
              (FowardB == 3'b011 ) ? 32'b0 : 
              (FowardB == 3'b100 ) ? pc_E + 4 :rdata2_E;

// alusrcmux u_alusrcmux (
//     .regnum(aluB),
//     .imm32(imm32_E),
//     .aluSrc(aluSrc_E),
//     .out(alu_B_E)
// );

assign alu_B_E = (aluSrc_E) ? imm32_E : aluB;

alu u_alu (
    .A(aluA),
    .B(alu_B_E),
    .ALUOp(aluOp_E),
    .result(alu_res_E)
);

MulDiv u_MulDiv (
    .clk(clk),
    .reset(reset),
    .we(hlwrite_E),
    .op(mdop_E),
    .a(aluA),
    .b(alu_B_E),
    .sel(hlsel_E),
    .start(mdstart_E),
    .busy(busy_E),
    .HI(HI_E),
    .LO(LO_E)
);

assign HLreg_E = (hlsel_E) ?  LO_E : HI_E;

assign data_E = (hlread_E) ? HLreg_E : alu_res_E;

EMreg u_EMreg (
    .clk(clk),
    .reset(reset | clrE2M),
    .stall(stallE2M),
    .pc(pc_E),
    .regaddr(regaddr_E),
    .alures(data_E),
    .memToReg(memToReg_E),
    .regWrite(regWrite_E),
    .rdata2(aluB),
    .memWrite(memWrite_E),
    .branch(branch_E),
    .jump(jump_E),
    .memByteen(memByteen_E),
    
    .memByteen_out(memByteen_M),
    .pc_out(pc_M),
    .regaddr_out(regaddr_M),
    .alures_out(alu_res_M),
    .memToReg_out(memToReg_M),
    .regWrite_out(regWrite_M),
    .rdata2_out(rdata2_M),
    .memWrite_out(memWrite_M),
    .branch_out(branch_M),
    .jump_out(jump_M)

);


// ---------------------------- MEM  -------------------------------- //
assign m_inst_addr = pc_M;
BE u_BE (
    .op(memByteen_M),
    .addr(alu_res_M),
    .data(rdata2_M),
    .memWrite(memWrite_M),
    .byteen(m_data_byteen),
    .data_out(m_data_wdata),
    .addr_out(m_data_addr)
);

DE u_DE(
    .addr(alu_res_M[1:0]),
    .Din(m_data_rdata),
    .Op(memByteen_M),
    .Dout(mem_res_M)
);


// dm u_dm (
//     .clk(clk),
//     .reset(reset),
//     .memWrite(memWrite_M),
//     .pc(pc_M),
//     .addr(alu_res_M),
//     .writeData(rdata2_M),
//     .readData(mem_res_M)
// );

// ---------------------------- WB  -------------------------------- //

WBreg u_WBreg (
    .clk(clk),
    .reset(reset),
    .stall(stallM2W),

    .memToReg(memToReg_M),
    .pc(pc_M),
    .memres(mem_res_M),
    .regWrite(regWrite_M),
    .regaddr(regaddr_M),
    .alures(alu_res_M),
    .jump(jump_M),

    .memToReg_out(memToReg_W),
    .pc_out(pc_W),
    .memres_out(mem_res_W),
    .regWrite_out(regWrite_W),
    .regaddr_out(regaddr_W),
    .alures_out(alu_res_W),
    .jump_out(jump_W)
);

// regwdatamux u_regwdatamux (
//     .aluout(alu_res_W),
//     .memout(mem_res_W),
//     .pc(pc_W),
//     .memToReg(memToReg_W),
//     .jump(jump_W),
//     .out(regwdata_W)
// );

assign regwdata_W = jump_W ? (pc_W + 8) :
                     (memToReg_W ? mem_res_W : alu_res_W);



endmodule
