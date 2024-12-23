module Bridge(
    input [3:0] byteen,
        input [31:0] addr,
    output reg [31:0] data_out,

    //DM
    input [31:0] DM_data,

    output reg [3:0] DM_byteen,



    //Timer0
    input [31:0] TC0_data,
    output reg TC0_we,

    //Timer1
    input [31:0] TC1_data,
    output reg TC1_we
);

reg _we;

always @(*) begin
    _we =(&(byteen));
    TC0_we = (addr >= 32'h7f00 && addr <= 32'h7f0b) ? _we : 0;
    TC1_we = (addr >= 32'h7f10 && addr <= 32'h7f1b) ? _we : 0;
    DM_byteen = (addr <= 32'h2fff) ? byteen : 4'b0000;


    if (addr <= 32'h2fff) begin
        data_out = DM_data;
    end
    else if(addr >= 32'h7f00 && addr <= 32'h7f0b) begin
        data_out = TC0_data;
    end
    else if(addr >= 32'h7f10 && addr <= 32'h7f1b) begin
        data_out = TC1_data;
    end
    else begin
        data_out = 32'b0;
    end
end


endmodule