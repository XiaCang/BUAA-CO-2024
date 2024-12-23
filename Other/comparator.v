module comparator(
    input [3:0] A,
    input [3:0] B,
    output Out
);

wire [3:0] A_;
wire [3:0] B_;

//isequal
reg out;

assign A_ = A + 4'b1000;
assign B_ = B + 4'b1000;

always @(*) begin
    if(A_[3] == B_[3])begin
        if(A_[2] == B_[2])begin
            if(A_[1] == B_[1])begin
                if(A_[0] == B_[0])begin
                    out = 0;
                end
                else if (A_[0] == 1) begin
                    out = 0;
                end
                else begin
                    out = 1;
                end
            end
            else if (A_[1] == 1) begin
                out = 0;
            end
            else begin
                out = 1;
            end
        end
        else if (A_[2] == 1) begin
            out = 0;
        end
        else begin
            out = 1;
        end
    end
    else if (A_[3] == 1) begin
        out = 0;
    end
    else begin
        out = 1;
    end
end

assign Out = out;

endmodule