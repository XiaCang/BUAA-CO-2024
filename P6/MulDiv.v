module MulDiv(
    input clk,
    input reset,
    input we,
    input [2:0] op,
    input [31:0] a,
    input [31:0] b,
    input  sel,
    input start,
    output reg busy,
    output reg [31:0] HI,
    output reg [31:0] LO
);

reg [31:0] counter;
reg [31:0] _HI;
reg [31:0] _LO;

always @(posedge clk) begin
    if (reset) begin
        counter <= 32'b0;
        _HI <= 32'b0;
        _LO <= 32'b0;
        HI <= 32'b0;
        LO <= 32'b0;
        busy <= 1'b0;
    end
    else begin
        if (counter == 32'b0) begin
            if (start) begin
                busy <= 1'b1;
                case (op) 
                    3'b000: begin //mult
                        counter <= 5;   
                        {_HI, _LO} <= $signed(a) * $signed(b);
                    end
                    3'b001: begin //multu
                        counter <= 5;
                        {_HI, _LO} <= a * b;
                    end
                    3'b010: begin //div
                        counter <= 10;
                        _HI <= $signed(a) % $signed(b);
                        _LO <= $signed(a) / $signed(b);
                    end
                    3'b011: begin //divu
                        counter <= 10;
                        _HI <= a % b;
                        _LO <= a / b;
                    end
                endcase
            end
            else begin
                counter <= 32'b0;
            end
        end
        else if(counter == 32'b1) begin
            if (start) begin
                case (op) 
                    3'b000: begin //mult
                        counter <= 5;   
                        {_HI, _LO} <= $signed(a) * $signed(b);
                    end
                    3'b001: begin //multu
                        counter <= 5;
                        {_HI, _LO} <= a * b;
                    end
                    3'b010: begin //div
                        counter <= 10;
                        _HI <= $signed(a) % $signed(b);
                        _LO <= $signed(a) / $signed(b);
                    end
                    3'b011: begin //divu
                        counter <= 10;
                        _HI <= a % b;
                        _LO <= a / b;
                    end
                endcase
            end
            else begin
                LO <= _LO;
                HI <= _HI;
                counter <= 32'b0;
                busy <= 1'b0;
            end

        end
        else begin
            if (start) begin
                case (op) 
                    3'b000: begin //mult
                        counter <= 5;   
                        {_HI, _LO} <= $signed(a) * $signed(b);
                    end
                    3'b001: begin //multu
                        counter <= 5;
                        {_HI, _LO} <= a * b;
                    end
                    3'b010: begin //div
                        counter <= 10;
                        _HI <= $signed(a) % $signed(b);
                        _LO <= $signed(a) / $signed(b);
                    end
                    3'b011: begin //divu
                        counter <= 10;
                        _HI <= a % b;
                        _LO <= a / b;
                    end
                endcase
            end
            else 
                counter <= counter - 32'b1;
        end

    end

    if (we && ~busy) begin
        if (sel) begin
            LO <= a;
        end
        else begin
            HI <= a;
        end
    end
end

endmodule