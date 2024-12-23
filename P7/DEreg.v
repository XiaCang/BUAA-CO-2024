module DEreg(
    input clk,
    input reset,
    input [31:0] pc,
    input [4:0] regaddr,
    input [31:0] rdata1,
    input [31:0] rdata2,
    input [31:0] imm32,
    input [2:0] aluOp,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input aluSrc,
    input memToReg,
    input regWrite,
    input memWrite,
    input branch,
    input jump,
    input stall,
    input [2:0] memByteen,
    input [2:0] mdop,
    input hlsel,
    input hlwrite,
    input hlread,
    input mdstart,
    input adEL_instr,
    input BD,
    input RI,
    input eret,
    input c0read,
    input c0write,
    input syscall,
    input req,
    input clr,
    output reg syscall_out,
    output reg c0write_out,
    output reg c0read_out,
    output reg eret_out,
    output reg RI_out,
    output reg BD_out,
    output reg adEL_instr_out,

    output reg [2:0] memByteen_out,
    output reg [2:0] mdop_out,
    output reg hlsel_out,
    output reg hlwrite_out,
    output reg hlread_out,
    output reg mdstart_out,
    output reg [31:0] pc_out,
    output reg [4:0] regaddr_out,
    output reg [31:0] rdata1_out,
    output reg [31:0] rdata2_out,
    output reg [31:0] imm32_out,
    output reg [2:0] aluOp_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg aluSrc_out,
    output reg memToReg_out,
    output reg regWrite_out,
    output reg memWrite_out,
    output reg branch_out,
    output reg jump_out
);

always @(posedge clk ) begin
    if (reset) begin
        pc_out <=  req ? 32'h4180 : clr ?  pc   : 32'h3000 ;
        regaddr_out <= 5'b0;
        rdata1_out <= 32'b0;
        rdata2_out <= 32'b0;
        imm32_out <= 32'b0;
        aluOp_out <= 3'b0;
        aluSrc_out <= 1'b0;
        memToReg_out <= 1'b0;
        regWrite_out <= 1'b0;
        memWrite_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        rs_out <= 5'b0;
        rt_out <= 5'b0;
        memByteen_out <= 3'b0;
        mdop_out <= 3'b0;
        hlsel_out <= 1'b0;
        hlwrite_out <= 1'b0;
        hlread_out <= 1'b0;
        mdstart_out <= 1'b0;
        syscall_out <= 1'b0;
        c0write_out <= 1'b0;
        c0read_out <= 1'b0;
        eret_out <= 1'b0;
        RI_out <= 1'b0;
        BD_out <= clr ? BD : 1'b0;
        adEL_instr_out <= 1'b0;
        rd_out <= 5'b0;
    end
    else if(stall) begin
        pc_out <= pc_out;
        regaddr_out <= regaddr_out;
        rdata1_out <= rdata1_out;
        rdata2_out <= rdata2_out;
        imm32_out <= imm32_out;
        aluOp_out <= aluOp_out;
        aluSrc_out <= aluSrc_out;
        memToReg_out <= memToReg_out;
        regWrite_out <= regWrite_out;
        memWrite_out <= memWrite_out;
        branch_out <= branch_out;
        jump_out <= jump_out;
        rs_out <= rs_out;
        rt_out <= rt_out;
        memByteen_out <= memByteen_out;
        mdop_out <= mdop_out;
        hlsel_out <= hlsel_out;
        hlwrite_out <= hlwrite_out;
        hlread_out <= hlread_out;
        mdstart_out <= mdstart_out;
        syscall_out <= syscall_out;
        c0write_out <= c0write_out;
        c0read_out <= c0read_out;
        eret_out <= eret_out;
        RI_out <= RI_out;
        BD_out <= BD_out;
        adEL_instr_out <= adEL_instr_out;
        rd_out <= rd_out;
    end
    else begin
        pc_out <= pc;
        regaddr_out <= regaddr;
        rdata1_out <= rdata1;
        rdata2_out <= rdata2;
        imm32_out <= imm32;
        aluOp_out <= aluOp;
        aluSrc_out <= aluSrc;
        memToReg_out <= memToReg;
        regWrite_out <= regWrite;
        memWrite_out <= memWrite;
        branch_out <= branch;
        jump_out <= jump;    
        rs_out <= rs;
        rt_out <= rt;
        memByteen_out <= memByteen;

        mdop_out <= mdop;
        hlsel_out <= hlsel;
        hlwrite_out <= hlwrite;
        hlread_out <= hlread;
        mdstart_out <= mdstart;
        syscall_out <= syscall;
        c0write_out <= c0write;
        c0read_out <= c0read;
        eret_out <= eret;
        RI_out <= RI;
        BD_out <= BD;
        adEL_instr_out <= adEL_instr;
        rd_out <= rd;
    end 
end

endmodule