module dm(
    input clk,
    input reset,
    input memWrite,
    input [31:0] pc,
    input [31:0] addr,
    input [31:0] writeData,
    output reg [31:0] readData
);

reg [31:0] mem [3071:0];

integer i=0;

always @(*) begin
    readData = mem[addr[13:2]];
end

always @(posedge clk) begin
    if (reset) begin
        for (i=0; i<=3071; i=i+1) begin
            mem[i] <= 32'b0;
        end
    end
    else if (memWrite) begin
        mem[addr[13:2]] <= writeData;
    end
end

always @(posedge clk) begin
    if (memWrite & ~reset) begin
        $display("%d@%h: *%h <= %h",$time ,pc, addr, writeData);
    end
end

endmodule