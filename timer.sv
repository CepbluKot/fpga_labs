module counter 
# (parameter max = 9)
(  input logic clk, reset,
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
(  input logic clk, reset,
  output logic clk_out);
  
  logic [31:0] counter_val;
  logic [31:0] prescaler_div;
  always_ff @(posedge clk)
  begin
    if (reset)
    begin
      clk_out <= 0;
      counter_val <= 0;
      prescaler_div <= prescaler_val >> 1;
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

 (  input logic [6:0] in0, 
  input logic [6:0] in1, 
  input logic [6:0] in2, 
  input logic [6:0] in3, 
  
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
  3: out = in3;
  default: out = in0; 
  endcase
  end
endmodule



module multiplexer_3

 (  input logic [3:0] in0, 
  input logic [3:0] in1, 
  input logic [3:0] in2, 
  input logic [3:0] in3, 
  
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
  3: out = in3;
  default: out = in0; 
  endcase
  end
endmodule


module device_new (input logic clk, reset,
          output logic[6:0] data_out,
          output logic[3:0] digit_out
          );
  
  
  logic[3:0] data;
  logic[3:0]  data_doli;
  logic[3:0]  data_secs;
  logic[3:0]  data_decs;
  logic[3:0]  data_hundreds;
  
  logic[6:0] data_out_doli;
  logic[6:0] data_out_secs;
  logic[6:0] data_out_decs;
  logic[6:0] data_out_hundreds;
logic[3:0] digit_out_doli;
  logic[3:0] digit_out_secs;
  logic[3:0] digit_out_decs;
  logic[3:0] digit_out_hundreds;
  
  
  logic reset_out;
  logic clk_out;
  assign reset_out = ~reset;
  assign clk_out = ~clk;
  
  prescaler #(50000000) prescaler_1 (clk_out, reset_out, clk_out_prescaler);
  
  prescaler #(50000000 / 60) prescaler_2 (clk_out, reset_out, clk_out_prescaler_2);
  prescaler #(50000000 ) prescaler_3 (clk_out, reset_out, clk_out_prescaler_3);
  prescaler #(50000000 * 60) prescaler_4 (clk_out, reset_out, clk_out_prescaler_4);
  prescaler #(50000000 * 600) prescaler_5 (clk_out, reset_out, clk_out_prescaler_5);
  prescaler #(50000) prescaler_mults (clk_out, reset_out, clk_out_prescaler_for_mults);
  
  
  
  counter #(9) cnt_9_doli(clk_out_prescaler_2, reset_out, data_doli);
  counter #(9) cnt_9_secs(clk_out_prescaler_3, reset_out, data_secs);
  counter #(9) cnt_9_decs(clk_out_prescaler_4, reset_out, data_decs);
  counter #(9) cnt_9_hundreds(clk_out_prescaler_5, reset_out, data_hundreds);
  
  
  logic [1:0] digit;
  counter #(3) cnt_3(clk_out_prescaler_for_mults, reset_out, digit);
  // decoder_7seg dec (data, digit, 0, data_out, digit_out, dp_out);
  
  decoder_7seg dec_1 (data_hundreds, 2'h0, 0, data_out_hundreds, digit_out_hundreds);
  decoder_7seg dec_2 (data_decs, 2'h1, 0, data_out_decs, digit_out_decs);
  decoder_7seg dec_3 (data_secs, 2'h2, 0, data_out_secs, digit_out_secs);
  decoder_7seg dec_4 (data_doli, 2'h3, 0, data_out_doli, digit_out_doli);
  
  
  
  
  multiplexer_6 mult_1  (data_out_hundreds, data_out_decs, data_out_secs, data_out_doli, digit, data_out);
  multiplexer_3 mult_2  (digit_out_hundreds, digit_out_decs, digit_out_secs, digit_out_doli, digit, digit_out);
  
  
endmodule



module decoder_7seg (input logic[3:0] data_in,
              input logic[1:0] digit_in,
              input logic dp_in,
              output logic[6:0] data_out,
              output logic[3:0] digit_out
              );
  always_comb
  begin

    case(data_in)
      4'h0: data_out = 7'b1000000 ;
      4'h1: data_out = 7'b1001111 ;
      4'h2: data_out = 7'b0100100 ;
      4'h3: data_out = 7'b0000110 ;
      4'h4: data_out = 7'b0001011 ;
      4'h5: data_out = 7'b0010010 ;
      4'h6: data_out = 7'b0010000 ;
      4'h7: data_out = 7'b1000111 ;
      4'h8: data_out = 7'b0000000 ;
      4'h9: data_out = 7'b0000010 ;
      default: data_out = 7'b1111110 ;
    endcase
    case(digit_in)
      2'h0: digit_out = 4'b1110 ;
      2'h1: digit_out = 4'b1101 ;
      2'h2: digit_out = 4'b1011 ;
      2'h3: digit_out = 4'b0111 ;
      default: digit_out = 4'b0000 ;
    endcase
  end
              
endmodule
