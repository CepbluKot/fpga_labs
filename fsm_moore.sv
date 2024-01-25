module counter 
# (parameter max = 3)
(	input logic clk, reset,
						output logic [3:0] out);
//always @ (posedge clk, negedge reset)
//always_ff @(posedge clk)
//always_latch @(clk)
//always_comb

always_ff @(posedge clk)
begin
	if (reset)
		out <= 0;
	else
	begin
		if (out == max)
			out <= 0;
		else
			out <= out + 1;
	end
end						
endmodule


module prescaler
# (parameter prescaler_val = 50000000)
(	input logic clk, reset,
	output logic clk_out);
	
	logic [31:0] counter_val;
	logic [31:0] prescaler_div;
	always_ff @(posedge clk)
	begin
		if (reset)
		begin
			clk_out = 0;
			counter_val = 0;
			prescaler_div = prescaler_val >> 1;
		end
		else
		begin
			if (counter_val == prescaler_div)
			begin
				clk_out <= clk_out ^ 1;
				counter_val <= 0;
			end
			else
				counter_val <= counter_val + 1;
		end
	end
endmodule



module multiplexer_6

 (	input logic [6:0] in0, 
	input logic [6:0] in1, 
	input logic [6:0] in2, 
	
	input logic [1:0] select, 
	output logic [6:0] out);
	/*
	logic [size-1:0] res1;
	logic [size-1:0] res2;
	
	always_comb
	begin
		res1 = select[0] ? in0 : in1;
		res2 = select[0] ? in2 : in3;
		out = select[1] ? res1 : res2;
	end
	*/
	always_comb
	begin
	case (select)
	0: out = in0;
	1: out = in1;
	2: out = in2;
	default: out = in0; 
	endcase
	end
endmodule


module multiplexer_3

 (	input logic [3:0] in0, 
	input logic [3:0] in1, 
	input logic [3:0] in2, 
	
	input logic [1:0] select, 
	output logic [3:0] out);
	/*
	logic [size-1:0] res1;
	logic [size-1:0] res2;
	
	always_comb
	begin
		res1 = select[0] ? in0 : in1;
		res2 = select[0] ? in2 : in3;
		out = select[1] ? res1 : res2;
	end
	*/
	always_comb
	begin
	case (select)
	0: out = in0;
	1: out = in1;
	2: out = in2;
	default: out = in0; 
	endcase
	end
endmodule

module finitestatemiachine (input logic clk, reset,
					output logic[6:0] data_out,
					output logic[3:0] digit_out
					);
		logic reset_out;
		logic clk_out;
		assign reset_out = ~reset;
		assign clk_out = ~clk;		
		
		logic [1:0]	state; 
		
		
		logic[6:0]	red_light_out_decoded;
		logic[6:0]	yellow_light_out_decoded;
		logic[6:0]	green_light_out_decoded;
		
		
		prescaler #(5000000 ) prescaler_counter_flick (clk_out, reset_out, clk_out_flickr_counter);
		prescaler #(50000000 * 2) prescaler_counter_state (clk_out, reset_out, clk_out_state_counter);
		prescaler #(50000) prescaler_mults (clk_out, reset_out, clk_out_prescaler_for_mults);
		
		
		logic [1:0] digit;
		counter #(3) cnt_3(clk_out_prescaler_for_mults, reset_out, digit);
		
		counter #(4) cnt_state(clk_out_state_counter, reset_out, state);
		
		
		always_ff
		begin	
			
			case(state)
				2'b00: begin

					red_light_out_decoded = 7'b1000000 ;
					yellow_light_out_decoded = 7'b1111111 ;
					green_light_out_decoded = 7'b1111111 ;

				end
				2'b01: begin
					red_light_out_decoded = 7'b1111111 ;
					yellow_light_out_decoded = 7'b1000000 ;
					green_light_out_decoded = 7'b1111111 ;

				end
				2'b10: begin
				
					red_light_out_decoded = 7'b1111111 ;
					yellow_light_out_decoded = 7'b1111111 ;	
					green_light_out_decoded = 7'b1000000;
	
				end
				
				2'b11: begin
					
					case(clk_out_flickr_counter)
		
						1'b0: begin
							red_light_out_decoded = 7'b1111111 ;
							yellow_light_out_decoded = 7'b1111111 ;	
							green_light_out_decoded = 7'b1000000;
						end
						
						1'b1: begin
							red_light_out_decoded = 7'b1111111 ;
							yellow_light_out_decoded = 7'b1111111 ;	
							green_light_out_decoded = 7'b1111111 ;
						end
						
					endcase
					
				end
				
			endcase
		end
		
		
		multiplexer_6 mult_1  (green_light_out_decoded, yellow_light_out_decoded, red_light_out_decoded, digit, data_out);
		multiplexer_3 mult_2  (4'b1110 , 4'b1101 , 4'b1011 , digit, digit_out);

endmodule
