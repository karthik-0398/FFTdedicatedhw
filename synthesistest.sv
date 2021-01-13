// synthesise to run on Altera DE0 for testing and demo
module synthesistest;
 logic clk, reset; // 50MHz Altera DE0 clock
 logic [7:0] SW; // Switches SW0..SW9
 logic [7:0] LED; // LEDs
  
 synthesis s1(.*) ;
initial
  begin
  clk = '0;
  #5ns reset = '0;
  #5ns reset = '1;
  #5ns reset = '0;
  forever #20ns clk = ~clk;
  end

initial 
  begin 
    SW = 8'h8 ;
  end
  
endmodule  