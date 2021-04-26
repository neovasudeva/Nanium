module ptable #(
    parameter w_bits = 8,
    parameter hist_len = 12
)
(
    input clk,
	input rst,

    /* reads from PC */
    input logic [3:0] r1_index,
    output logic [w_bits-1:0] perc1_out [hist_len+1],

    /* reads/writes from EX/MEM PC for training */
    input logic [3:0] r2_index,
    output logic [w_bits-1:0] perc2_out [hist_len+1],
    input logic wr_en,
    input logic [w_bits-1:0] perc2_in [hist_len+1]
);

/********************************* DATA ARRAY ********************************/ 
// NOTE: hist_len + 1 because extra weight for bias
logic [w_bits-1:0] data [16][hist_len+1] = '{default: '0};
/*****************************************************************************/

/******************************** READS/WRITES *******************************/ 
assign perc1_out = data[r1_index];
assign perc2_out = data[r2_index];

always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < hist_len+1; j++) begin
                data[i][j] <= '0;
            end
        end
    end
    else if (wr_en) 
        data[r2_index] <= perc2_in;
end
/*****************************************************************************/

endmodule : ptable