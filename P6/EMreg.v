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
        pc_out <= 32'h3000;
        regaddr_out <= 5'b0;
        alures_out <= 32'b0;
        memToReg_out <= 1'b0;
        regWrite_out <= 1'b0;
        rdata2_out <= 32'b0;
        memWrite_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        memByteen_out <= 3'b0;      
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
    end
end

endmodule