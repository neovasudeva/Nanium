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
                    data[0][windex] <= '0;
                    data[1][windex] <= '0;
                    data[3][windex] <= '0;
                end
                3'd1: begin
                    data[0][windex] <= '0;
                    data[1][windex] <= '0;
                    data[3][windex] <= '1;
                end
                3'd2: begin
                    data[0][windex] <= '0;
                    data[1][windex] <= '1;
                    data[4][windex] <= '0;
                end
                3'd3: begin
                    data[0][windex] <= '0;
                    data[1][windex] <= '1;
                    data[4][windex] <= '1;
                end
                3'd4: begin
                    data[0][windex] <= '1;
                    data[2][windex] <= '0;
                    data[5][windex] <= '0;
                end
                3'd5: begin
                    data[0][windex] <= '1;
                    data[2][windex] <= '0;
                    data[5][windex] <= '1;
                end
                3'd6: begin
                    data[0][windex] <= '1;
                    data[2][windex] <= '1;
                    data[6][windex] <= '0;
                end
                3'd7: begin
                    data[0][windex] <= '1;
                    data[2][windex] <= '1;
                    data[6][windex] <= '1;
                end
                default: ;
            endcase
        end
    end
end

always_comb begin
    if (data[0][rindex]) begin
        if (data[1][rindex]) begin
            if (data[3][rindex]) begin
                plru = 3'd0;
            end else begin
                plru = 3'd1;
            end
        end else begin
            if (data[4][rindex]) begin
                plru = 3'd2;
            end else begin
                plru = 3'd3;
            end
        end
    end else begin
        if (data[2][rindex]) begin
            if (data[5][rindex]) begin
                plru = 3'd4;
            end else begin
                plru = 3'd5;
            end
        end else begin
            if (data[6][rindex]) begin
                plru = 3'd6;
            end else begin
                plru = 3'd7;
            end
        end
    end
end

endmodule : plru
