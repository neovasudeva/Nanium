module plru #(
    parameter s_index = 3,
    parameter width = 1
)
(
    input clk,
    input rst,
    input load,
    input [width-1:0] mru,
    output logic [width-1:0] plru
);

localparam num_sets = 2**s_index;

logic [width-1:0] data /*[num_sets-1:0] /* synthesis ramstyle = "logic" */;
assign plru = data;

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < 1 /*num_sets*/; ++i)
            data[i] <= '1;
    end
    else begin
        if(load) begin
            unique case (mru)
                1'd0: begin
                    data[0] <= '0;
                end
                1'd1: begin
                    data[0] <= '1;
                end
                default: ;
            endcase
        end
    end
end

endmodule : plru
