`timescale  1ns / 1ps

module tb_counter;

// counter Parameters
parameter PERIOD  = 10;


// counter Inputs
reg   Clk                                  = 0 ;
reg   Reset                                = 0 ;
reg   Slt                                  = 0 ;
reg   En                                   = 0 ;

// counter Outputs
wire  [63:0]  Output0                      ;
wire  [63:0]  Output1                      ;

code  u_counter (
    .Clk                     ( Clk             ),
    .Reset                   ( Reset           ),
    .Slt                     ( Slt             ),
    .En                      ( En              ),

    .Output0                 ( Output0  [63:0] ),
    .Output1                 ( Output1  [63:0] )
)
;
always #5 Clk=~Clk;

initial
begin
    $dumpfile("wave.vcd");
    $dumpvars;

    Reset = 1;
    Slt=1;
    En=1;
    #10
    Reset=0;
    #200
    Slt=0;
    #200
    $finish;
end

endmodule