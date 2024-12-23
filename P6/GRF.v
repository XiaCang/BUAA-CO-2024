module grf(
    input clk,
    input reset,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    input wenable,
    output [31:0] rdata1,
    output [31:0] rdata2

);

reg [31:0] regfile [31:0];

assign rdata1 = (waddr==raddr1&&waddr!=0&&wenable)?wdata: regfile[raddr1];
assign rdata2 = (waddr==raddr2&&waddr!=0&&wenable)?wdata: regfile[raddr2];
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

endmodule