module PC(
    input clk,
    input reset,
    input stall,
    input req,
    input [31:0] next_pc,
    output reg [31:0] pc
);

reg [31:0] _pc;


always @(posedge clk) begin
    if (reset) begin
        _pc <= 32'h00003000;
    end    
    else if(req) begin
        _pc <= 32'h4180;
    end
    else if (stall) begin
        _pc <= _pc;
    end

    else begin
        _pc <= next_pc;
    end
end


always @(*) begin
    pc = _pc;
end


endmodule