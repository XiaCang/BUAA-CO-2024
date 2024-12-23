module DE(
    input [1:0] addr,
    input [31:0] Din,
    input [2:0] Op,
    output reg [31:0] Dout
);


always @(*) begin
    case(Op)
        3'b000: Dout = Din;
        3'b001: begin // unsigned byte
            case(addr)
                2'b00: Dout = {24'b0, Din[7:0]};
                2'b01: Dout = {24'b0, Din[15:8]};
                2'b10: Dout = {24'b0, Din[23:16]};
                2'b11: Dout = {24'b0, Din[31:24]};
            endcase
        end 
        3'b010: begin // signed byte
            case(addr)
                2'b00: Dout = {{24{Din[7]}}, Din[7:0]};
                2'b01: Dout = {{24{Din[15]}}, Din[15:8]};
                2'b10: Dout = {{24{Din[23]}}, Din[23:16]};
                2'b11: Dout = {{24{Din[31]}}, Din[31:24]};
            endcase
        end
        3'b011: begin // unsigned halfword
            case(addr[1])
                1'b0: Dout = {16'b0, Din[15:0]};
                1'b1: Dout = {16'b0, Din[31:16]};
            endcase
        end
        3'b100: begin // signed halfword
            case(addr[1])
                1'b0: Dout = {{16{Din[15]}}, Din[15:0]};
                1'b1: Dout = {{16{Din[31]}}, Din[31:16]};
            endcase
        end
        default: Dout = Din;
    endcase
end

endmodule