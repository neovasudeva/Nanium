module plru #(
    parameter s_index = 3,
    parameter width = 3
)
(
    input clk,
    input rst,
    input load,
    input logic [s_index-1:0] rindex,
    input logic [s_index-1:0] windex,
    input logic [width-1:0] mru,
    output logic [width-1:0] plru
);

localparam num_sets = 2**s_index;

logic [width-1:0] data [num_sets-2:0];

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets-1; ++i)
            data[i] <= '1;
    end
    else begin
        if(load) begin
            unique case (mru)
                3'd0: begin
                    data[windex][0] <= '0;
                    data[windex][1] <= '0;
                    data[windex][3] <= '0;
                end
                3'd1: begin
                    data[windex][0] <= '0;
                    data[windex][1] <= '0;
                    data[windex][3] <= '1;
                end
                3'd2: begin
                    data[windex][0] <= '0;
                    data[windex][1] <= '1;
                    data[windex][4] <= '0;
                end
                3'd3: begin
                    data[windex][0] <= '0;
                    data[windex][1] <= '1;
                    data[windex][4] <= '1;
                end
                3'd4: begin
                    data[windex][0] <= '1;
                    data[windex][2] <= '0;
                    data[windex][5] <= '0;
                end
                3'd5: begin
                    data[windex][0] <= '1;
                    data[windex][2] <= '0;
                    data[windex][5] <= '1;
                end
                3'd6: begin
                    data[windex][0] <= '1;
                    data[windex][2] <= '1;
                    data[windex][6] <= '0;
                end
                3'd7: begin
                    data[windex][0] <= '1;
                    data[windex][2] <= '1;
                    data[windex][6] <= '1;
                end
                default: ;
            endcase
        end
    end
end

always_comb begin
    if (data[rindex][0]) begin
        if (data[rindex][1]) begin
            if (data[rindex][3]) begin
                plru = 3'd0;
            end else begin
                plru = 3'd1;
            end
        end else begin
            if (data[rindex][4]) begin
                plru = 3'd2;
            end else begin
                plru = 3'd3;
            end
        end
    end else begin
        if (data[rindex][2]) begin
            if (data[rindex][5]) begin
                plru = 3'd4;
            end else begin
                plru = 3'd5;
            end
        end else begin
            if (data[rindex][6]) begin
                plru = 3'd6;
            end else begin
                plru = 3'd7;
            end
        end
    end
end

endmodule : plru
