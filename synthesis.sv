//-----------------------------------------------------------------
// File Name   : synthesis.sv
// Function    : FFT transform 
// Version: 2,  
// Author:  ks6n19
// Last rev.  13/01/21
// Comments: Replaced assign with always_comb in ymul1 and ymul2. 
//			 This might be the reason for non inference of 
// 			 multipliers. Excessive amounts of registers in design. 
//------------------------------------------------------------------

module synthesis(input logic clk,  // 10Hz clock 
				input logic reset, // master reset (active low push button)
				input logic signed[7:0] SW,				// connected to switches
				output logic[7:0] LED);// this will be the ALU output   
				
	enum { idle, wait_1, wait_2, wait_3, wait_4, wait_5, wait_6, wait_7, wait_8, alu_1, alu_2, alu_3, disp_R1, disp_R2, disp_I1, disp_I2, read_rew, read_rea, read_reb, read_imw, read_ima, read_imb } state ;
logic s0, s1, s2, s3,s5, s6;
logic signed [7:0] rew ;
logic signed [7:0] imw ;
logic signed [7:0] rea ;
logic signed [7:0] ima ;
logic signed [7:0] reb ;
logic signed [7:0] imb ;
logic signed [7:0] A_1; 
logic signed [7:0]a_2; 
logic signed [7:0]B_1; 
logic signed [7:0]b_2;
logic signed [7:0] X ;
logic signed [7:0] Y ;
logic signed [7:0] R2 ;
logic signed [7:0] R1 ;
logic signed [7:0] I2 ;
logic signed [7:0] I1 ;
logic signed [15:0] ymul1;
logic signed [15:0] ymul2 ;
logic [7:0] sub_temp;
logic [7:0] sub2 ;
logic [7:0] sub_1 ;
logic [7:0] result_sub ;
logic signed [7:0] y1;
logic signed [7:0] y4;
logic signed [7:0] y2;
logic signed [7:0] y3; 
logic [7:0] result_add ;
logic [7:0] add_1 ;
logic [7:0] add_2 ;
always_ff@(posedge clk or posedge reset)
	begin	
		SEQ :
		if(reset)
				begin
					state<=idle ;
					rew <= '0;
					imw <= '0;
					rea <= '0;
					ima <= '0;
					reb <= '0;
					imb <= '0;
					X <= '0 ;
					Y <= '0 ;
					R1 <= '0 ;
					R2 <= '0 ;
					I1 <= '0 ;
					I2 <= '0 ;
					s0 <= '0 ;
					s1 <= '0 ;
					s2 <= '0 ;
					s3 <= '0 ;
					s5 <= '0 ;
					s6 <= '0 ;
					
				end
			else
				begin
					unique casez(state)
						 idle : 
								begin
									state<= wait_1 ;
								end
					
						wait_1 :
								begin
									state<= read_rew ;
								end
						
						read_rew : 
								begin
									rew <= SW ;
									state<= wait_2 ;
								end
								
						wait_2 :
								begin
									state<= read_imw ;
								end	
								
						read_imw : 
								begin 
									imw<= SW ;
									state<= wait_3 ;
								end
						wait_3 :
								begin 
									state<= read_reb ;
								end
						
						read_reb :
								begin 
									reb<=SW;
									state<= wait_4 ;
								end		
						
						wait_4 :
								begin 
									s0<= '1 ;
									s1<= '1;
									state<= read_imb ;
								end		
								
						read_imb :
								begin 
									A_1<= ymul1[14:7] ;
									B_1<= ymul2[14:7] ;
									imb<=SW[7:0] ;
									state<=wait_5 ;
								end		
								
						wait_5 :
								begin
									s0<= '0 ;
									s0<= '0 ;
									state<= read_rea ;
								end		
								
						read_rea :
								begin 
									a_2<= ymul1[14:7];
									b_2<= ymul2[14:7];
									rea<=SW[7:0] ;
									state<= wait_6 ;
								end			
								
						wait_6 :
								begin
									s2<= '1 ;
									s3<= '0 ;
									s5<= '1 ;
									s6<= '0 ;
									state<= read_ima ;
								end	
						read_ima :
								begin 
									ima<=SW[7:0] ;
									state<= alu_1 ;
								end				

						alu_1 	:
								begin
									X<=result_sub ;
									Y<= result_add ;
									state<= wait_7 ;
								end							
						
						wait_7 	:
								begin
									s2<= '1;
									s3<= '1 ;
									s5<= '1 ;
									s6<= '1 ;
									state<= alu_2 ;
								end							
						alu_2 	:
								begin
									R2<=result_sub ;
									R1<= result_add ;
									state<= wait_8 ;
								end		
								
						wait_8 	:
								begin
									s2<='0 ;
									s3<='1 ;
									s5<='0 ;
									s6<='1 ;
									state<= alu_3;
								end			
						
						alu_3 :
								begin 
									I1<= result_add ;
									I2<= result_sub ;
									state<= disp_R1 ;
								end		
						disp_R1:
								begin
									LED<= R1 ;
									state<=disp_I1 ;
								end
						disp_I1:
								begin
									LED<= I1 ;
									state<=disp_R2 ;
								end
						disp_R2:
								begin
									LED<= R2 ;
									state<= disp_I2 ;
								end
						disp_I2:
								begin
									LED<= I2 ;
									state<= idle ;
								end
									
										
						
						
						
								
					endcase
				end	
	end 
	
	// subtractor  result_sub
	always_comb
		begin
			sub_temp = ~sub2 + 1'b1; // 2's complement subtrahend
			result_sub = sub_1 + sub_temp ; // n-bit subtractor
		end // always_comb

// embedded multipliers 
	always_comb 
		begin 
			ymul1 = y1 * y4 ;
			ymul2 = y2 * y3 ;
		end 		
//mux 1 for op 1 and 4 
always_c1omb 
	begin
		if(s0)
			begin
				y1 = rew;  // [1] 
				y4 = reb;  // 1
			end	
		else
			begin
				y1 = imw;  // [4]
				y4 = imb;  // 0
			end
	end 

//mux 2 for op 2 and 3
always_comb 
	begin
		if(s1)
			begin
				y2 = reb;  // [2] 
				y3 = imw;  // 1
			end
		else
			begin
				y2 = rew;  // [3]
				y3 = imb;  // 0
			end
	end
//mux 1 sub 
always_comb 
	begin
		if(s2)
			begin
				sub_1 = A_1;  // [X] 
				sub2 = a_2;  // s2
			end
				if(s3)
					begin
						sub_1 = rea;  // [R2]
						sub2 = X;  // s3 s2
					end
		else
			begin
				sub_1 = ima;  // [I2]
				sub2 = Y;  // s4
			end
	end
// mux 2 add 
always_comb 
	begin
		if(s5)
			begin
				add_1 = B_1;  // [Y] 
				add_2 = b_2;  // s5
			end
				if(s6)
					begin
						add_1 = rea;  // [R1]
						add_2 = X;  // s6
					end
		else 
			begin
				add_1 = ima;  // [I1]
				add_2 = Y;  // s7
			end
	end	
	
//adder result_add
always_comb
begin
   result_add = add_1 + add_2 ; // n-bit adder
end // always_comb	
	// port map registers and mux in always comb for mul and add operations 

endmodule 