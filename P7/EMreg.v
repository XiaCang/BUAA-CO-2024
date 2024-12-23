module EMreg(
    input clk,
    input reset,
    input stall,
    input [31:0] pc,
    input [4:0] regaddr,
    input [31:0] alures,
    input memToReg,
    input regWrite,
    input [31:0] rdata2,
    input memWrite,
    input branch,
    input jump,
    input [2:0] memByteen,

    input adEL_instr,
    input BD,
    input RI,
    input eret,
    input c0read,
    input c0write,
    input syscall,
    input req,
    input overflow,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,

    output reg overflow_out,

    output reg syscall_out,
    output reg c0write_out,
    output reg c0read_out,
    output reg eret_out,
    output reg RI_out,
    output reg BD_out,
    output reg adEL_instr_out,

    output reg [2:0] memByteen_out,
    output reg [31:0] pc_out,
    output reg [4:0] regaddr_out,
    output reg [31:0] alures_out,
    output reg memToReg_out,
    output reg regWrite_out,
    output reg [31:0] rdata2_out,
    output reg memWrite_out,
    output reg branch_out,
    output reg jump_out
);

always @(posedge clk ) begin
    if (reset) begin
        pc_out <= req ? 32'h4180 : 32'h3000;
        regaddr_out <= 5'b0;
        alures_out <= 32'b0;
        memToReg_out <= 1'b0;
        regWrite_out <= 1'b0;
        rdata2_out <= 32'b0;
        memWrite_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        memByteen_out <= 3'b0;  
        syscall_out <= 1'b0;
        c0write_out <= 1'b0;
        c0read_out <= 1'b0;
        eret_out <= 1'b0;
        RI_out <= 1'b0;
        BD_out <= 1'b0;
        adEL_instr_out <= 1'b0;   
        overflow_out <= 1'b0; 
        rs_out <= 5'b0;
        rt_out <= 5'b0;
        rd_out <= 5'b0;
    end
    else if(stall) begin
        pc_out <= pc_out;
        regaddr_out <= regaddr_out;
        alures_out <= alures_out;
        memToReg_out <= memToReg_out;
        regWrite_out <= regWrite_out;
        rdata2_out <= rdata2_out;
        memWrite_out <= memWrite_out;
        branch_out <= branch_out;
        jump_out <= jump_out;
        memByteen_out <= memByteen_out;
        syscall_out <= syscall_out;
        c0write_out <= c0write_out;
        c0read_out <= c0read_out;
        eret_out <= eret_out;
        RI_out <= RI_out;
        BD_out <= BD_out;
        adEL_instr_out <= adEL_instr_out;
        overflow_out <= overflow_out;
        rs_out <= rs_out;
        rt_out <= rt_out;
        rd_out <= rd_out;
    end
    else begin
        pc_out <= pc;
        regaddr_out <= regaddr;
        alures_out <= alures;
        memToReg_out <= memToReg;
        regWrite_out <= regWrite;
        rdata2_out <= rdata2;
        memWrite_out <= memWrite;
        branch_out <= branch;
        jump_out <= jump;
        memByteen_out <= memByteen;
        syscall_out <= syscall;
        c0write_out <= c0write;
        c0read_out <= c0read;
        eret_out <= eret;
        RI_out <= RI;
        BD_out <= BD;
        adEL_instr_out <= adEL_instr;
        overflow_out <= overflow;
        rs_out <= rs;
        rt_out <= rt;
        rd_out <= rd;
    end
end

endmodule