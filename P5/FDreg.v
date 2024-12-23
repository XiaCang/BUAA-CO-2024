module FDreg(
    input clk,
    input reset,
    input  stall,
    input [31:0] instr,
    input [31:0] pc,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
    
);


always @(posedge clk ) begin
    if (reset) begin
        instr_out <= 32'b0;
        pc_out <= 32'h3000;
    end
    else if (stall) begin
        instr_out <= instr_out;
        pc_out <= pc_out;
    end
    else begin
        instr_out <= instr;
        pc_out <= pc;
    end
    
end

endmodule