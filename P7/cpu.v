module cpu(
    input clk,
    input reset,
    input [5:0] HWInt,
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
wire [31:0] pc_F_tmp;
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
wire [4:0] rd_E;
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
wire [4:0] rs_M;
wire [4:0] rt_M;
wire [4:0] rd_M;
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
wire clrM2W;
wire clearDelaySlot;
wire [31:0] rs_cmp;
wire [31:0] rt_cmp;

wire [4:0] ExcCode_M;

wire adEL_instr_F;
wire adEL_instr_D;
wire adEL_instr_E;
wire adEL_instr_M;
wire adEL_M;
wire adES_M;

wire overflow_E;
wire overflow_M;

wire BD_F;
wire BD_D;
wire BD_E;
wire BD_M;

wire eret_D;
wire eret_E;
wire eret_M;

wire c0read_D;
wire c0read_E;
wire c0read_M;
wire c0read_W;

wire c0write_D;
wire c0write_E;
wire c0write_M;
wire syscall_D;
wire syscall_E;
wire syscall_M;

wire RI_D;
wire RI_E;
wire RI_M;

wire [31:0] EPC;
wire [31:0] cp0_data_M;
wire [31:0] cp0_data_W;
wire req;
wire IntResponse;

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
    .req(req), 
    .c0readE(c0read_E), 
    .c0writeM(c0write_M),
    .eretD(eret_D),
    .c0writeE(c0write_E),
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
    .ClrE2M(clrE2M),
    .ClrM2W(clrM2W)  
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
    .req(req),
    .next_pc(nextpc_F),
    .pc(pc_F_tmp)
);

assign BD_F = branch_D || jump_D || jr_D;

assign pc_F = (eret_D) ? EPC : pc_F_tmp;

assign adEL_instr_F = ((pc_F[1:0] != 2'b00 || pc_F < 32'h3000 || pc_F > 32'h6ffc)&& !eret_D);

assign i_inst_addr = pc_F;
//extract IM 
assign instr_F = (adEL_instr_F) ? 32'b0 : i_inst_rdata;

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
    .reset(reset | clrF2D | req),
    .stall(stallF2D),
    .instr(instr_F),
    .pc(pc_F),
    .BD(BD_F),
    .adEL_instr(adEL_instr_F),
    .req(req),
    .BD_out(BD_D),
    .adEL_instr_out(adEL_instr_D),
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
    .mdstart(mdstart_D),
    .RI(RI_D),
    .eret(eret_D),
    .c0read(c0read_D),
    .c0write(c0write_D),
    .syscall(syscall_D)
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
    .reset(reset | clrD2E | req),
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
    .rd(rd_D),
    .stall(stallD2E),

    .memByteen(memByteen_D),

    .mdop(mdop_D),
    .hlsel(hlsel_D),
    .hlread(hlread_D),
    .hlwrite(hlwrite_D),
    .mdstart(mdstart_D),

    .adEL_instr(adEL_instr_D),       // 输入: 地址异常指令标志
    .BD(BD_D),               // 输入: 延迟槽标志
    .RI(RI_D),               // 输入: 保留指令异常
    .eret(eret_D),             // 输入: 返回异常处理信号
    .c0read(c0read_D),           // 输入: 读取 CP0 信号
    .c0write(c0write_D),          // 输入: 写入 CP0 信号
    .syscall(syscall_D),          // 输入: 系统调用信号
    .req(req),
    .clr(clrD2E),
    .syscall_out(syscall_E),      // 输出: 系统调用标志
    .c0write_out(c0write_E),      // 输出: 写入 CP0 标志
    .c0read_out(c0read_E),       // 输出: 读取 CP0 标志
    .eret_out(eret_E),         // 输出: 返回异常处理标志
    .RI_out(RI_E),           // 输出: 保留指令异常标志
    .BD_out(BD_E),           // 输出: 延迟槽标志
    .adEL_instr_out(adEL_instr_E),    // 输出: 地址异常指令标志

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
    .rt_out(rt_E),
    .rd_out(rd_E)
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
    .result(alu_res_E),
    .Overflow(overflow_E)
);

MulDiv u_MulDiv (
    .clk(clk),
    .reset(reset),
    .we(hlwrite_E & ~req),
    .op(mdop_E),
    .a(aluA),
    .b(alu_B_E),
    .sel(hlsel_E),
    .start(mdstart_E & ~req),
    .busy(busy_E),
    .HI(HI_E),
    .LO(LO_E)
);

assign HLreg_E = (hlsel_E) ?  LO_E : HI_E;

assign data_E = (hlread_E) ? HLreg_E : alu_res_E;



EMreg u_EMreg (
    .clk(clk),
    .reset(reset | clrE2M | req),
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

    .adEL_instr(adEL_instr_E),       // 输入: 地址异常指令标志
    .BD(BD_E),               // 输入: 延迟槽标志
    .RI(RI_E),               // 输入: 保留指令异常
    .eret(eret_E),             // 输入: 返回异常处理信号
    .c0read(c0read_E),           // 输入: 读取 CP0 信号
    .c0write(c0write_E),          // 输入: 写入 CP0 信号
    .syscall(syscall_E),          // 输入: 系统调用信号
    .overflow(overflow_E),        // 输入: 溢出标志
    .rs(rs_E),
    .rt(rt_E),
    .rd(rd_E),
    .rd_out(rd_M),
    .rs_out(rs_M),
    .rt_out(rt_M),
    .req(req),
    .overflow_out(overflow_M),    // 输出: 溢出标志
    .syscall_out(syscall_M),      // 输出: 系统调用标志
    .c0write_out(c0write_M),      // 输出: 写入 CP0 标志
    .c0read_out(c0read_M),       // 输出: 读取 CP0 标志
    .eret_out(eret_M),         // 输出: 返回异常处理标志
    .RI_out(RI_M),           // 输出: 保留指令异常标志
    .BD_out(BD_M),           // 输出: 延迟槽标志
    .adEL_instr_out(adEL_instr_M),    // 输出: 地址异常指令标志

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
    .req(req),
    .data_out(m_data_wdata),
    .addr_out(m_data_addr)
);

DE u_DE(
    .addr(alu_res_M[1:0]),
    .Din(m_data_rdata),
    .Op(memByteen_M),
    .Dout(mem_res_M)
);

CheckMemExcption u_CheckMemExcption (
    .op(memByteen_M), 
    .addr(alu_res_M),         // 输入: 内存地址 (32位)
    .memWrite(memWrite_M),     // 输入: 内存写信号
    .memtoreg(memToReg_M),
    .aluOverflow(overflow_M),  // 输入: ALU 溢出信号
    .adEL(adEL_M),          // 输出: 地址异常标志
    .adES(adES_M)
);

assign ExcCode_M = (adEL_instr_M) ? 5'd4 :
                    (RI_M) ? 5'd10 :
                    (adEL_M) ? 5'd4 :
                    (adES_M) ? 5'd5 :
                    (overflow_M) ? 5'd12 :
                    (syscall_M) ? 5'd8 :
                    5'd0;

// CP0 instance
CP0 u_CP0 (
    .clk(clk),         // 时钟信号
    .reset(reset),       // 复位信号
    .we(c0write_M),          // 写使能信号
    .addr1(rd_M),       // 读地址
    .addr2(rd_M),       // 写地址
    .in(rdata2_M),          // 输入数据
    .out(cp0_data_M),         // 输出数据
    .EPC(pc_M),         // 输入的异常程序计数器
    .BD(BD_M),          // 延迟槽标志
    .ExcCodeIn(ExcCode_M),   // 输入的异常代码
    .HWInt(HWInt),       // 硬件中断信号
    .EXLClr(eret_M),      // 清除 EXL 标志
    .EPCOut(EPC),      // 输出的异常程序计数器
    .Req(req)          // 中断或异常请求

);


// ---------------------------- WB  -------------------------------- //

WBreg u_WBreg (
    .clk(clk),
    .reset(reset | clrM2W | req),
    .stall(stallM2W),

    .memToReg(memToReg_M),
    .pc(pc_M),
    .memres(mem_res_M),
    .regWrite(regWrite_M),
    .regaddr(regaddr_M),
    .alures(alu_res_M),
    .jump(jump_M),
    .cp0data(cp0_data_M),

    .cp0read(c0read_M),
    .cp0read_out(cp0read_W),

    .cp0data_out(cp0_data_W),
    .memToReg_out(memToReg_W),
    .pc_out(pc_W),
    .memres_out(mem_res_W),
    .regWrite_out(regWrite_W),
    .regaddr_out(regaddr_W),
    .alures_out(alu_res_W),
    .jump_out(jump_W)
);


assign regwdata_W = jump_W ? (pc_W + 8) :
                    cp0read_W ? cp0_data_W :
                     (memToReg_W ? mem_res_W : alu_res_W);



endmodule
