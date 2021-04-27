module btb_array #(
    parameter width = 32,
    parameter bit_entry = 5,
    parameter num_entry = 2**bit_entry
)
(
    input clk,
    input rst,
    input load,
    input logic [bit_entry-1:0] rindex,
    input logic [bit_entry-1:0] windex,
    input logic [width-1:0] din,
    output logic [width-1:0] dout
);

logic [width-1:0] data [num_entry] = '{default: 0};

// out
assign dout = (rindex == windex) ? din : data[rindex];

// load in
always_ff @(posedge clk) begin
    if (rst)
        for (int i = 0; i < num_entry; i++)
            data[i] <= {width{1'b0}};
    else if (load)
        data[windex] <= din;
end

endmodule : btb_array