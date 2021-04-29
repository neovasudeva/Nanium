module shift_reg #(parameter width = 12) 
(
    input clk,
    input rst,
    input load,
    input in,
    output [width-1:0] out
);

logic [width-1:0] data = '0; 

assign out = data;

always_ff @(posedge clk) begin
    if (rst)
        data <= '0;
    else if (load)
        data <= {data[width-2:0], in};
end

endmodule : shift_reg