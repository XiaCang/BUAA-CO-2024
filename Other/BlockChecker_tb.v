`timescale  1ns / 1ps

module tb_BlockChecker;

// BlockChecker Parameters
parameter PERIOD  = 10;


// BlockChecker Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [7:0]  in                            = 0 ;

// BlockChecker Outputs
wire  result                               ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


BlockChecker  u_BlockChecker (
    .clk                     ( clk           ),
    .reset                   ( reset         ),
    .in                      ( in      [7:0] ),

    .result                  ( result        )
);

initial
begin
    $dumpfile("BlockChecker.vcd");
    $dumpvars();

    reset = 1;
    in = "a";
    #2;
    reset = 0;
    #8 in = " ";
    #10 in = "B";
    #10 in = "E";
    #10 in = "g";
    #10 in = "I";
    #10 in = "n";
    #10 in = " ";
    #10 in = "E";
    #10 in = "n";
    #10 in = "d";
    #10 in = " ";
   
    #10 in = "e";
    #10 in = "n";
    #10 in = "d";
 #10 in = "c";
    #10 in = " ";

    #10 in = "e";
    #10 in = "n";
    #10 in = "d";
    #10 in = "v";

        #10 in = " ";
    #10 in = "n";
    #10 in = "d";
    #10 in = "c";
    #10 in = " ";
    #10 in = "b";
    #10 in = "e";
    #10 in = "G";
    #10 in = "i";
    #10 in = "n";
    #100




    $finish;
end

endmodule