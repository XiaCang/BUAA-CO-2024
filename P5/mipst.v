`timescale  1ns / 1ps

module tb_mips;

// mips Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;

initial
begin
    forever #5  clk=~clk;
end

mips  u_mips (
    .clk                     ( clk     ),
    .reset                   ( reset   )
);

initial
begin
    $dumpfile("mipst.vcd");
    $dumpvars;
    reset  = 1;
    
    #20;
    reset  = 0;

    #20000;


    $finish;
end

endmodule