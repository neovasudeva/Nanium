package cache_out_mux;
typedef enum bit {
    way_0  = 1'b0
    ,way_1  = 1'b1
} cache_out_mux_sel_t;
endpackage

package pmem_addr_mux;
typedef enum bit [1:0] {
    cpu  = 2'b00
    ,dirty_0_write = 2'b01
    ,dirty_1_write = 2'b10
} pmem_addr_mux_sel_t;
endpackage

package data_in_mux;
typedef enum bit {
    cacheline_adaptor  = 1'b0
    ,bus_adaptor = 1'b1
} data_in_mux_sel_t;
endpackage

package data_write_en_mux;
typedef enum bit [1:0]{
    idle  = 2'b00
    ,load_mem = 2'b01
    ,cpu_write = 2'b10
} data_write_en_mux_sel_t;
endpackage
