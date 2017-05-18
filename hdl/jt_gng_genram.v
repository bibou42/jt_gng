`timescale 1ns/1ps

/*

	Generic RAM

*/

module jt_gng_genram #(parameter addrw=12, dataw=8)(
	input [addrw-1:0] A,
	inout [dataw-1:0] D,
	input cs_b,
	input rd_b,
	input wr_b
);

reg [dataw-1:0] ram [0:(2**addrw-1)];
reg [dataw-1:0] dread;

wire READ = !cs_b && !rd_b;
wire WRITE= !cs_b && !wr_b;

assign D= READ ? dread : 8'hzz;

// always @(READ)
// 	if(READ)
// 		$display("RAM read %X from %X",dread, A);

always @(A) begin
	dread=ram[A];
end

always @(WRITE,A)
	if(WRITE) begin
		//$display("RAM write %X into %X",D, A);
		ram[A]=D;
	end


endmodule // jt_gng_ram