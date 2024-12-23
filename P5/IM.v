module im(
    input clk,
    input reset,
    input stall,
    input [31:0] next_pc,
    output reg [31:0] instr,
    output reg [31:0] pc
);

reg [31:0] instruction [4095:0];
reg [31:0] _pc;
reg [31:0] _pc_to_mem;

initial begin
    $readmemh("code.txt", instruction);
end

always @(posedge clk) begin
    if (reset) begin
        _pc <= 32'h00003000;
        _pc_to_mem<= 0;
    end
    else if (stall) begin
        _pc <= _pc;
        _pc_to_mem <= _pc_to_mem;
    end
    else begin
        _pc <= next_pc;
        _pc_to_mem <= next_pc - 12288;
    end
end


always @(*) begin
    pc = _pc;
    instr = instruction[_pc_to_mem[13:2]];
end


endmodule