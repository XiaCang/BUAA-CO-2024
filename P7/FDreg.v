module FDreg(
    input clk,
    input reset,
    input  stall,
    input [31:0] instr,
    input [31:0] pc,
    input BD,
    input adEL_instr,
    input req,
    output reg adEL_instr_out,
    output reg BD_out,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
    
);


always @(posedge clk ) begin
    if (reset) begin
        instr_out <= 32'b0;
        pc_out <= req ? 32'h4180 : 32'h3000;
        adEL_instr_out <= 5'b0;
        BD_out <= 1'b0;
    end
    else if (stall) begin
        instr_out <= instr_out;
        pc_out <= pc_out;
        adEL_instr_out <= adEL_instr_out;
        BD_out <= BD_out;
    end
    else begin
        instr_out <= instr;
        pc_out <= pc;
        adEL_instr_out <= adEL_instr;
        BD_out <= BD;
    end
    
end

endmodule