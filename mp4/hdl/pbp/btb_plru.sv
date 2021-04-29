module btb_plru #(
    parameter b_sets = 3,
    parameter way = 4
)(
    input clk,
    input rst,
    input read,                         // only update read pLRU if btb hit on read
    input load,
    input logic [b_sets-1:0] r_index,   // read set index
    input logic [b_sets-1:0] w_index,   // write set index
    input [1:0] r_mru,                  // way read accessed
    input [1:0] w_mru,                  // way written to
    output logic [1:0] plru             // way to write to (IF MISS ON W_INDEX)
);

localparam b_way = way - 1;
localparam n_sets = 2**b_sets;

logic [b_way-1:0] data [n_sets];

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < n_sets; i++)
            data[i] <= {b_way{1'b0}};
    end
    else begin
        // reading (update mru)
        if(read) begin
            unique case (r_mru)
                2'd0: begin
                    data[r_index][0] <= '0;
                    data[r_index][1] <= '0;
                end
                2'd1: begin
                    data[r_index][0] <= '0;
                    data[r_index][1] <= '1;
                end
                2'd2: begin
                    data[r_index][0] <= '1;
                    data[r_index][2] <= '0;
                end
                2'd3: begin
                    data[r_index][0] <= '1;
                    data[r_index][2] <= '1;
                end
                default: ;
            endcase
        end

        // writing (update mru)
        if(load) begin
            unique case (w_mru)
                2'd0: begin
                    data[w_index][0] <= '0;
                    data[w_index][1] <= '0;
                end
                2'd1: begin
                    data[w_index][0] <= '0;
                    data[w_index][1] <= '1;
                end
                2'd2: begin
                    data[w_index][0] <= '1;
                    data[w_index][2] <= '0;
                end
                2'd3: begin
                    data[w_index][0] <= '1;
                    data[w_index][2] <= '1;
                end
                default: ;
            endcase
        end
    end
end

always_comb begin
    // get way to write to from tree
    if (load) begin
        if (data[w_index][0]) begin
            if (data[w_index][1]) 
                plru = 2'b00;
            else 
                plru = 2'b01;
        end 
        else begin
            if (data[w_index][2])
                plru = 2'b10;
            else     
                plru = 2'b11;
        end
    end 
	else 
		plru = 2'b00;	// default
end

endmodule : btb_plru