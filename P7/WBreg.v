module WBreg(
    input clk,
    input reset,
    input stall,
    input [31:0] pc,
    input [4:0] regaddr,
    input [31:0] alures,
    input [31:0] memres,
    input memToReg,
    input regWrite,
    input jump,
    input [31:0] cp0data,
    input cp0read,
    output reg cp0read_out,
    output reg [31:0] cp0data_out,
    output reg [31:0] pc_out,
    output reg [4:0] regaddr_out,
    output reg [31:0] alures_out,
    output reg [31:0] memres_out,
    output reg memToReg_out,
    output reg regWrite_out,
    output reg jump_out
);

always @(posedge clk ) begin
    if (reset) begin
        pc_out <= 32'h3000;
        regaddr_out <= 5'b0;
        alures_out <= 32'b0;
        memres_out <= 32'b0;
        memToReg_out <= 1'b0;
        regWrite_out <= 1'b0;
        jump_out <= 1'b0;
        cp0data_out <= 32'b0;
        cp0read_out <= 1'b0;
    end
    else if (stall) begin
        pc_out <= pc_out;
        regaddr_out <= regaddr_out;
        alures_out <= alures_out;
        memres_out <= memres_out;
        memToReg_out <= memToReg_out;
        regWrite_out <= regWrite_out;
        jump_out <= jump_out;
        cp0data_out <= cp0data_out;
        cp0read_out <= cp0read_out;
    end
    else begin
        pc_out <= pc;
        regaddr_out <= regaddr;
        alures_out <= alures;
        memres_out <= memres;
        memToReg_out <= memToReg;
        regWrite_out <= regWrite;
        jump_out <= jump;
        cp0data_out <= cp0data;
        cp0read_out <= cp0read;
    end
end

endmodule