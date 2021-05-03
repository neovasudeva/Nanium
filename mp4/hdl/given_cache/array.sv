
module array #(parameter width = 1)
(
  input clk,
  input logic load,
  input logic [3:0] rindex,
  input logic [3:0] windex,
  input logic [width-1:0] datain,
  output logic [width-1:0] dataout
);

//logic [width-1:0] data [2:0] = '{default: '0};
logic [width-1:0] data [16];
initial begin
  data[0] = 0;
  data[1] = 0;
  data[2] = 0;
  data[3] = 0;
  data[4] = 0;
  data[5] = 0;
  data[6] = 0;
  data[7] = 0;
  data[8] = 0;
  data[9] = 0;
  data[10] = 0;
  data[11] = 0;
  data[12] = 0;
  data[13] = 0;
  data[14] = 0;
  data[15] = 0;
end

always_comb begin
  dataout = (load  & (rindex == windex)) ? datain : data[rindex];
end

always_ff @(posedge clk)
begin
    if(load)
        data[windex] <= datain;
end

endmodule : array
