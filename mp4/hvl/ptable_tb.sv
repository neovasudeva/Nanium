module ptable_tb ();
`timescale 1ns/10ps

logic clk, rst, wr_en;
logic [3:0] r1_index, r2_index;
logic [7:0] perc1_out [13];
logic [7:0] perc2_out [13];
logic [7:0] perc2_in [13];

logic [7:0] perc2_prod [13];
always_comb begin
	for (int i = 0; i < 13; i++)
		perc2_prod[i] = (perc2_out[i][7] == 1'b1) ? (perc2_out[i] ^ {8{1'b1}}) : perc2_out[i];	
end

logic [7:0] data [2][3] = '{'{8'b00000100, 8'b00000010, 8'b00000100},
							'{8'b00000010, 8'b00000000, 8'b11111111}};

always begin : CLOCK_GENERATION
    #10000;
    clk = ~clk;
end

initial begin
	clk = 1;
	r1_index = 4'b0;
	r2_index = 4'b1;
	wr_en = 1'b1;
	for (int i = 0; i < 13; i++)
		perc2_in[i] = $urandom;
	
	#10000;
	
	r1_index = 4'b1;
	r2_index = 4'b1;
	wr_en = 1'b1;
	for (int i = 0; i < 13; i++)
		perc2_in[i] = $urandom;
	
	#10000;
	
	r1_index = 4'b1;
	r2_index = 4'b1;
	wr_en = 1'b0;
	for (int i = 0; i < 13; i++)
		perc2_in[i] = $urandom;
	
	#10000;
	
	rst = 1'b1;
	
	#10000;

	//$display("%0b", ($signed(8'hff) < 8'h00));
	//$display("%0h", data[1].sum with (item[7] == 1 ? 8'b1 : item));
	$display("%0h", $signed(8'hFB) >= 0 ? 8'hFB : (8'hFB ^ {8{1'b1}}) + 1);
	//$display("%0h", data[0][0] + 8'hFF);
	$finish;
end

// dut
ptable #(.w_bits(8), .hist_len(12)) ptable(.*);

endmodule 