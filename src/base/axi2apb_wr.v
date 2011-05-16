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

INCLUDE def_axi2apb.txt
OUTFILE PREFIX_wr.v

module  PREFIX_wr (PORTS);

   input 		          clk;
   input 		          reset;
   
   input                  GROUP_APB3;
      
   input                  cmd_err;
   input [ID_BITS-1:0]    cmd_id;
   output                 finish_wr;
   
   port                   WGROUP_APB_AXI_W;
   port                   BGROUP_APB_AXI_B;
   
   
   parameter              RESP_OK     = 2'b00;
   parameter              RESP_SLVERR = 2'b10;
   parameter              RESP_DECERR = 2'b11;
   
   reg                    BGROUP_APB_AXI_B.OUT;
   
   
   assign                 finish_wr = BVALID & BREADY;
   
   assign                 WREADY = psel & penable & pwrite & pready;
   
   always @(posedge clk or posedge reset)
     if (reset)
	   begin
         BGROUP_APB_AXI_B.OUT <= #FFD {GROUP_APB_AXI_B.OUT.WIDTH{1'b0}};
	   end
	 else if (finish_wr)
	   begin
         BGROUP_APB_AXI_B.OUT <= #FFD {GROUP_APB_AXI_B.OUT.WIDTH{1'b0}};
	   end
	 else if (psel & penable & pwrite & pready)
	   begin
	     BID    <= #FFD cmd_id;
		 BRESP  <= #FFD cmd_err ? RESP_SLVERR : pslverr ? RESP_DECERR : RESP_OK;
		 BVALID <= #FFD 1'b1;
	   end
	   
endmodule

   
