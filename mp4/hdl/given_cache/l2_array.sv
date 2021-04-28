/* A register array to be used for tag arrays, LRU array, etc. */

module l2_array #(
    parameter s_index = 3,
    parameter width = 1
)
(
    clk,
    rst,
    load,
    index,
    datain,
    dataout
);

localparam num_sets = 2**s_index;

input clk;
input rst;
input load;
input [s_index-1:0] index;
input [width-1:0] datain;
output logic [width-1:0] dataout;

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
//logic [width-1:0] _dataout;
assign dataout = (load) ? datain : data[index];

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
//        _dataout <= (load) ? datain : data[index];

        if(load)
            data[index] <= datain;
    end
end

endmodule : l2_array
