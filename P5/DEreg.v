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
    input aluSrc,
    input memToReg,
    input regWrite,
    input memWrite,
    input branch,
    input jump,
    input stall,
    output reg [31:0] pc_out,
    output reg [4:0] regaddr_out,
    output reg [31:0] rdata1_out,
    output reg [31:0] rdata2_out,
    output reg [31:0] imm32_out,
    output reg [2:0] aluOp_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg aluSrc_out,
    output reg memToReg_out,
    output reg regWrite_out,
    output reg memWrite_out,
    output reg branch_out,
    output reg jump_out


);

always @(posedge clk ) begin
    if (reset) begin
        pc_out <= 32'h3000;
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
    end 
end

endmodule