/*  This file is part of JT_GNG.
    JT_GNG program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT_GNG program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT_GNG.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 19-11-2018 */

module jtbtiger_video(
    input               rst,
    input               clk,
    input               cen12,
    input               cen8,
    input               cen6,
    input               cen3,
    input               cpu_cen,
    input       [11:0]  cpu_AB,
    input       [ 7:0]  V,
    input       [ 8:0]  H,
    input               RnW,
    input               flip,
    input       [ 7:0]  cpu_dout,
    input               pause,
    // CHAR
    input               char_cs,
    output      [ 7:0]  char_dout,
    input               char_ok,
    output              char_busy,
    output      [13:0]  char_addr,
    input       [15:0]  char_data,
    input               CHRON,
    // SCROLL - ROM
    input               scr_cs,
    output      [ 7:0]  scr_dout,
    output      [16:0]  scr_addr,
    input       [15:0]  scr_data,
    input               scr_ok,
    output              scr_busy,
    input       [10:0]  scr_hpos,
    input       [10:0]  scr_vpos,
    input       [ 1:0]  scr_bank,
    input               scr_layout,
    input               SCRON,
    // OBJ
    input               HINIT,
    output      [ 8:0]  obj_AB,
    input       [ 7:0]  main_ram,
    input               OKOUT,
    output              bus_req, // Request bus
    input               bus_ack, // bus acknowledge
    output              blcnten,    // bus line counter enable
    output      [16:0]  obj_addr,
    input       [15:0]  obj_data,
    input               obj_ok,
    input               OBJON,
    // Color Mix
    input               LVBL,
    input               LVBL_obj,
    input               LHBL,
    input               LHBL_obj,
    output              LHBL_dly,
    output              LVBL_dly,
    // Palette PROMs
    input       [7:0]   prog_addr,
    input               prom_prior_we,
    input       [3:0]   prom_din,
    // Palette RAM
    input               blue_cs,
    input               redgreen_cs,
    input       [3:0]   gfx_en,
    // Pixel output
    output      [3:0]   red,
    output      [3:0]   green,
    output      [3:0]   blue
);

localparam OBJMAX       = 10'h200, // DMA buffer 512 bytes = 4*128
           OBJMAX_LINE  = 6'd32,
           AVATAR_MAX   = 9;

wire [6:0] char_pxl;
wire [6:0] obj_pxl;
wire [7:0] scr_pxl;
wire [3:0] cc;
wire [3:0] avatar_idx;

`ifndef NOCHAR

wire [7:0] char_msg_low;
wire [7:0] char_msg_high=8'h0;
wire [9:0] char_scan;

jtgng_char #(
    .HOFFSET ( 0),
    .ROM_AW  (14),
    .PALW    ( 5),
    .VFLIP_EN( 0),
    .HFLIP_EN( 0),
    .IDMSB0  ( 5)
) u_char (
    .clk        ( clk           ),
    .pxl_cen    ( cen6          ),
    .cpu_cen    ( cpu_cen       ),
    .AB         ( cpu_AB[10:0]  ),
    .V          ( V             ),
    .H          ( H[7:0]        ),
    .flip       ( flip          ),
    .din        ( cpu_dout      ),
    .dout       ( char_dout     ),
    // Bus arbitrion
    .char_cs    ( char_cs       ),
    .wr_n       ( RnW           ),
    .busy       ( char_busy     ),
    // Pause screen
    .pause      ( pause         ),
    .scan       ( char_scan     ),
    .msg_low    ( char_msg_low  ),
    .msg_high   ( char_msg_high ),
    // ROM
    .char_addr  ( char_addr     ),
    .rom_data   ( char_data     ),
    .rom_ok     ( char_ok       ),
    // Pixel output
    .char_on    ( 1'b1          ),
    .char_pxl   ( char_pxl      ),
    // unused
    .dseln      (               ),
    .prog_addr  (               ),
    .prog_din   (               ),
    .prom_we    (               )
);

jtgng_charmsg #(.VERTICAL(0)) u_msg(
    .clk         ( clk           ),
    .cen6        ( cen6          ),
    .avatar_idx  ( avatar_idx    ),
    .scan        ( char_scan     ),
    .msg_low     ( char_msg_low  ),
    .msg_high    (               )
);
`else
assign char_pxl  = ~7'd0;
assign char_mrdy = 1'b1;
`endif

`ifndef NOSCR
wire [7:0] scr_pre;

jtframe_sh #(.width(8),.stages(5)) u_hb_dly(
    .clk    ( clk      ),
    .clk_en ( cen6     ),
    .din    ( scr_pre  ),
    .drop   ( scr_pxl  )
);

jtbtiger_scroll #(.HOFFSET(0)) u_scroll (
    .clk        ( clk           ),
    .pxl_cen    ( cen6          ),
    .cpu_cen    ( cpu_cen       ),
    // screen position
    .H          ( H             ),
    .V          ( V[7:0]        ),
    .Hinit      ( HINIT         ),
    .hpos       ( scr_hpos      ),
    .vpos       ( scr_vpos      ),
    .flip       ( flip          ),
    .layout     ( scr_layout    ),
    .bank       ( scr_bank      ),
    // bus arbitrion
    .AB         ( cpu_AB[11:0]  ),
    .scr_cs     ( scr_cs        ),
    .din        ( cpu_dout      ),
    .dout       ( scr_dout      ),
    .wr_n       ( RnW           ),
    .busy       ( scr_busy      ),
    // ROM
    .scr_addr   ( scr_addr      ),
    .rom_data   ( scr_data      ),
    .rom_ok     ( scr_ok        ),
    // pixel output
    .scr_pxl    ( scr_pre       )
);
`else
assign scr_busy   = 1'b0;
assign scr_pxl    = 8'hff;
assign scr_addr   = 17'd0;
assign scr_dout   = 8'd0;
`endif

`ifndef NOOBJ
jtgng_obj #(
    .OBJMAX       ( OBJMAX      ),
    .OBJMAX_LINE  ( OBJMAX_LINE ),
    .ROM_AW       ( 17          ),
    .PALW         (  3          ),
    .PXL_DLY      (  8          ),
    .LAYOUT       (  4          ),
    .AVATAR_MAX   ( AVATAR_MAX  ),
    .VERTICAL     ( 0           ))
u_obj (
    .rst        ( rst         ),
    .clk        ( clk         ),
    .draw_cen   ( cen12       ),
    .dma_cen    ( cen8        ),
    .pxl_cen    ( cen6        ),
    .AB         ( obj_AB      ),
    .DB         ( main_ram    ),
    .OKOUT      ( OKOUT       ),
    .bus_req    ( bus_req     ),
    .bus_ack    ( bus_ack     ),
    .blen       ( blcnten     ),
    .LHBL       ( LHBL_obj    ),
    .LVBL       ( LVBL        ),
    .LVBL_obj   ( LVBL_obj    ),
    .HINIT      ( HINIT       ),
    .flip       ( flip        ),
    .V          ( V[7:0]      ),
    .H          ( H           ),
    // avatar display
    .pause      ( pause       ),
    .avatar_idx ( avatar_idx  ),
    // SDRAM interface
    .obj_addr   ( obj_addr    ),
    .obj_data   ( obj_data    ),
    .rom_ok     ( obj_ok      ),
    // pixel data
    .obj_pxl    ( obj_pxl     ),
    // unused
    .prog_addr  (             ),
    .prog_din   (             ),
    .prom_hi_we ( 1'b0        ),
    .prom_lo_we ( 1'b0        ),
    .OBJON      ( 1'b1        )
);
`else
assign blcnten = 1'b0;
assign bus_req = 1'b0;
assign obj_pxl = ~6'd0;
`endif

`ifndef NOCOLMIX
jtbtiger_colmix u_colmix (
    .rst          ( rst           ),
    .clk          ( clk           ),
    .cen12        ( cen12         ),
    .cen6         ( cen6          ),

    .char_pxl     ( char_pxl      ),
    .scr_pxl      ( scr_pxl       ),
    .obj_pxl      ( obj_pxl       ),
    .LVBL         ( LVBL          ),
    .LHBL         ( LHBL          ),
    .LHBL_dly     ( LHBL_dly      ),
    .LVBL_dly     ( LVBL_dly      ),

    // Priority PROM
    .prog_addr    ( prog_addr     ),
    .prom_prior_we( prom_prior_we ),
    .prom_din     ( prom_din      ),

    // Avatars
    .pause        ( pause         ),
    .avatar_idx   ( avatar_idx    ),

    // Layer control
    .CHRON        ( CHRON         ),
    .SCRON        ( SCRON         ),
    .OBJON        ( OBJON         ),

    // DEBUG
    .gfx_en       ( gfx_en        ),

    // CPU interface
    .AB           ( cpu_AB[9:0]   ),
    .blue_cs      ( blue_cs       ),
    .redgreen_cs  ( redgreen_cs   ),
    .DB           ( cpu_dout      ),

    // colour output
    .red          ( red           ),
    .green        ( green         ),
    .blue         ( blue          )
);
`else
assign  red = 4'd0;
assign blue = 4'd0;
assign green= 4'd0;
`endif

endmodule