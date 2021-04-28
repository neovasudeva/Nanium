/* A special register array specifically for your
data arrays. This module supports a write mask to
help you update the values in the array. */

module l2_data_array #(
    parameter s_offset = 5,
    parameter s_index = 3
)
(
    clk,
    rst,
    write_en,
    index,
    datain,
    dataout
);

localparam s_mask   = 2**s_offset;
localparam s_line   = 8*s_mask;
localparam num_sets = 2**s_index;

input clk;
input rst;
input logic write_en;
input [s_index-1:0] index;
input [s_line-1:0] datain;
output logic [s_line-1:0] dataout;

logic [s_line-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
assign dataout = data[index];

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
		if (write_en) data[index] <= datain;
    end
end

endmodule : l2_data_array
