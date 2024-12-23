module grf(
    input clk,
    input reset,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    input wenable,
    input [31:0] PC,
    output [31:0] rdata1,
    output [31:0] rdata2

);

reg [31:0] regfile [31:0];

assign rdata1 = regfile[raddr1];
assign rdata2 = regfile[raddr2];
integer i;
always @(posedge clk) begin
    if(reset) begin
        i=0;
        for (i=0;i<32;i=i+1) begin
            regfile[i]=32'b0;
        end
    end
    else begin 
        if(wenable && waddr!=0) begin
            regfile[waddr]=wdata;
        end
    end
end

always @(posedge clk) begin
    if(wenable & ~reset) begin
        $display("@%h: $%d <= %h", PC, waddr, wdata);
    end
end

endmodule