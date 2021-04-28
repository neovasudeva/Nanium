module plru #(
    parameter s_index = 3,
    parameter width = 1
)
(
    input clk,
    input rst,
    input load,
    input logic [2:0] index,
    input [2:0] mru,
    output logic [2:0] plru
);

localparam n_sets = 2**s_index;
logic [6:0] data [n_sets];

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < 7; ++i)
            data[i] <= '1;
    end
    else begin
        if(load) begin
            unique case (mru)
                3'd0: begin
                    data[index][0] <= '0;
                    data[index][1] <= '0;
                    data[index][3] <= '0;
                end
                3'd1: begin
                    data[index][0] <= '0;
                    data[index][1] <= '0;
                    data[index][3] <= '1;
                end
                3'd2: begin
                    data[index][0] <= '0;
                    data[index][1] <= '1;
                    data[index][4] <= '0;
                end
                3'd3: begin
                    data[index][0] <= '0;
                    data[index][1] <= '1;
                    data[index][4] <= '1;
                end
                3'd4: begin
                    data[index][0] <= '1;
                    data[index][2] <= '0;
                    data[index][5] <= '0;
                end
                3'd5: begin
                    data[index][0] <= '1;
                    data[index][2] <= '0;
                    data[index][5] <= '1;
                end
                3'd6: begin
                    data[index][0] <= '1;
                    data[index][2] <= '1;
                    data[index][6] <= '0;
                end
                3'd7: begin
                    data[index][0] <= '1;
                    data[index][2] <= '1;
                    data[index][6] <= '1;
                end
                default: ;
            endcase
        end
    end
end

always_comb begin
    if (data[index][0]) begin
        if (data[index][1]) begin
            if (data[index][3]) begin
                plru = 3'd0;
            end else begin
                plru = 3'd1;
            end
        end else begin
            if (data[index][4]) begin
                plru = 3'd2;
            end else begin
                plru = 3'd3;
            end
        end
    end else begin
        if (data[index][2]) begin
            if (data[index][5]) begin
                plru = 3'd4;
            end else begin
                plru = 3'd5;
            end
        end else begin
            if (data[index][6]) begin
                plru = 3'd6;
            end else begin
                plru = 3'd7;
            end
        end
    end
end

endmodule : plru