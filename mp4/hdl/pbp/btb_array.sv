module btb_array #(
    parameter width = 32,
    parameter bit_entry = 3
)(
    input clk,
    input rst,
    input load,
    input logic [bit_entry-1:0] r_index,
    input logic [bit_entry-1:0] w_index,
    input logic [width-1:0] w_din,
    output logic [width-1:0] r_dout,
    output logic [width-1:0] w_dout
);

localparam num_entry = 2**bit_entry;

logic [width-1:0] data [num_entry] = '{default: 0};

// out
assign r_dout = (load && (r_index == w_index)) ? w_din : data[r_index];
assign w_dout = data[w_index];

// load in
always_ff @(posedge clk) begin
    if (rst)
        for (int i = 0; i < num_entry; i++)
            data[i] <= {width{1'b0}};
    else if (load)
        data[w_index] <= w_din;
end

endmodule : btb_array