module BE(
    input [2:0] op,
    input [31:0] addr,
    input [31:0] data,
    input memWrite,
    output reg [3:0] byteen,
    output reg [31:0] data_out,
    output reg [31:0] addr_out
);

always @(*) begin
    addr_out = addr;
    
    if (memWrite) begin
        case (op)
            3'b000: begin //word
                byteen = 4'b1111;
                data_out = data;
            end
            3'b001: begin //byte
                if (addr[1:0] == 2'b00) begin
                    byteen = 4'b0001;
                    data_out = {24'b0, data[7:0]};
                end else if (addr[1:0] == 2'b01) begin
                    byteen = 4'b0010;
                    data_out = {16'b0, data[7:0], 8'b0};
                end else if (addr[1:0] == 2'b10) begin
                    byteen = 4'b0100;
                    data_out = {8'b0, data[7:0], 16'b0};
                end else begin
                    byteen = 4'b1000;
                    data_out = {data[7:0], 24'b0};
                end
            end
            3'b010:begin //byte
                if (addr[1:0] == 2'b00) begin
                    byteen = 4'b0001;
                    data_out = {24'b0, data[7:0]};
                end else if (addr[1:0] == 2'b01) begin
                    byteen = 4'b0010;
                    data_out = {16'b0,data[7:0], 8'b0};
                end else if (addr[1:0] == 2'b10) begin
                    byteen = 4'b0100;
                    data_out = {8'b0, data[7:0], 16'b0};
                end else begin
                    byteen = 4'b1000;
                    data_out = {data[7:0], 24'b0};
                end
            end
            3'b011: begin //halfword
                if (addr[1]) begin
                    byteen = 4'b1100;
                    data_out = {data[15:0], 16'b0};
                end else begin
                    byteen = 4'b0011;
                    data_out = {16'b0, data[15:0]};
                end
            end
            3'b100:begin //halfword
                if (addr[1]) begin
                    byteen = 4'b1100;
                    data_out = {data[15:0], 16'b0};
                end else begin
                    byteen = 4'b0011;
                    data_out = {16'b0, data[15:0]};
                end
            end

            default : begin
                byteen = 4'b0000;
                data_out = 32'b0;
            end
        endcase
    end else begin
        byteen = 4'b0000;
        data_out = 32'b0;
    end
end

endmodule