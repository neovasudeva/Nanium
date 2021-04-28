package pmem_addr_mux;
typedef enum bit [3:0] {
    cpu  = 4'd0
    ,dirty_0_write = 4'd1
    ,dirty_1_write = 4'd2
    ,dirty_2_write = 4'd3
    ,dirty_3_write = 4'd4
    ,dirty_4_write = 4'd5
    ,dirty_5_write = 4'd6
    ,dirty_6_write = 4'd7
    ,dirty_7_write = 4'd8
} pmem_addr_mux_sel_t;
endpackage

package data_in_mux;
typedef enum bit {
    cacheline_adaptor  = 1'b0
    ,bus_adaptor = 1'b1
} data_in_mux_sel_t;
endpackage

package data_write_en_mux;
typedef enum bit {
    idle  = 1'b0
    ,load_mem = 1'b1
} data_write_en_mux_sel_t;
endpackage
