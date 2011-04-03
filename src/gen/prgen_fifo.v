<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE prgen_fifo.v

ITER DX 1 15
module prgen_fifo(PORTS);

   parameter                  WIDTH      = 8;
   parameter                  DEPTH_FULL = 8;

   parameter 		      SINGLE     = DEPTH_FULL == 1;
   parameter 		      DEPTH      = SINGLE ? 1 : DEPTH_FULL -1;
   parameter 		      DEPTH_BITS = 
			      (DEPTH <= EXPR(2^DX)) ? DX :
                              0; //0 is ilegal

   parameter 		      LAST_LINE  = DEPTH-1;
   
   

   input                      clk;
   input                      reset;

   input 		      push;
   input 		      pop;
   input [WIDTH-1:0] 	      din;
   output [WIDTH-1:0] 	      dout;
   output 		      empty;
   output 		      full;
   

   wire 		      reg_push;
   wire 		      reg_pop;
   wire 		      fifo_push;
   wire 		      fifo_pop;
   
   reg [DEPTH-1:0] 	      fullness_in;
   reg [DEPTH-1:0] 	      fullness_out;
   reg [DEPTH-1:0] 	      fullness;
   reg [WIDTH-1:0] 	      fifo [DEPTH-1:0];
   wire 		      fifo_empty;
   wire 		      next;
   reg [WIDTH-1:0] 	      dout;
   reg 			      dout_empty;
   reg [DEPTH_BITS-1:0]       ptr_in;
   reg [DEPTH_BITS-1:0]       ptr_out;
   
   


   assign 		      reg_push  = push & fifo_empty & (dout_empty | pop);
   assign 		      reg_pop   = pop & fifo_empty;
   assign 		      fifo_push = !SINGLE & push & (~reg_push);
   assign 		      fifo_pop  = !SINGLE & pop & (~reg_pop);
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  dout       <= #FFD {WIDTH{1'b0}};
	  dout_empty <= #FFD 1'b1;
       end
     else if (reg_push)
       begin
	  dout       <= #FFD din;
	  dout_empty <= #FFD 1'b0;
       end
     else if (reg_pop)
       begin
	  dout       <= #FFD {WIDTH{1'b0}};
	  dout_empty <= #FFD 1'b1;
       end
     else if (fifo_pop)
       begin
	  dout       <= #FFD fifo[ptr_out];
	  dout_empty <= #FFD 1'b0;
       end
   
   always @(posedge clk or posedge reset)
     if (reset)
       ptr_in <= #FFD {DEPTH_BITS{1'b0}};
     else if (fifo_push)
       ptr_in <= #FFD ptr_in == LAST_LINE ? 0 : ptr_in + 1'b1;

   always @(posedge clk or posedge reset)
     if (reset)
       ptr_out <= #FFD {DEPTH_BITS{1'b0}};
     else if (fifo_pop)
       ptr_out <= #FFD ptr_out == LAST_LINE ? 0 : ptr_out + 1'b1;

   always @(posedge clk)
     if (fifo_push)
       fifo[ptr_in] <= #FFD din;

   
   always @(*)
     begin
	fullness_in = {DEPTH{1'b0}};
	fullness_in[ptr_in] = fifo_push;
     end
   
   always @(*)
     begin
	fullness_out = {DEPTH{1'b0}};
	fullness_out[ptr_out] = fifo_pop;
     end
   
   always @(posedge clk or posedge reset)
     if (reset)
       fullness <= #FFD {DEPTH{1'b0}};
     else if (fifo_push | fifo_pop)
       fullness <= #FFD (fullness & (~fullness_out)) | fullness_in;


   assign next       = |fullness;
   assign fifo_empty = ~next;
   assign empty      = fifo_empty & dout_empty;
   assign full       = SINGLE ? !dout_empty : &fullness;

endmodule


