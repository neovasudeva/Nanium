onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mp4_tb/dut/clk
add wave -noupdate /mp4_tb/dut/rst
add wave -noupdate -group Stalls/Forwards /mp4_tb/dut/datapath/cache_stall
add wave -noupdate -group Stalls/Forwards /mp4_tb/dut/datapath/branch_rst
add wave -noupdate -group Stalls/Forwards /mp4_tb/dut/datapath/forward_stall
add wave -noupdate -group Stalls/Forwards /mp4_tb/dut/datapath/forwarding_unit/fstall_rs1
add wave -noupdate -group Stalls/Forwards /mp4_tb/dut/datapath/forwarding_unit/fstall_rs2
add wave -noupdate -group IF /mp4_tb/dut/datapath/pc_rst
add wave -noupdate -group IF /mp4_tb/dut/datapath/pc_load
add wave -noupdate -group IF /mp4_tb/dut/datapath/if_pc
add wave -noupdate -group IF /mp4_tb/dut/datapath/if_instruction
add wave -noupdate -group IF /mp4_tb/dut/datapath/pcmux_out
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/ifid_rst
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/ifid_load
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/ifid_pc
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/ifid_instruction
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/id_ctrl_word
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/id_rs1_out
add wave -noupdate -group IF/ID /mp4_tb/dut/datapath/id_rs2_out
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_rst
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_load
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_instruction
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_ctrl_word
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_pc
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_rs2_out
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/idex_rs1_out
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/rs1mux_sel
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/rs2mux_sel
add wave -noupdate -group ID/EX /mp4_tb/dut/datapath/dcacheforwardmux_sel
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_rst
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_load
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_instruction
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_ctrl_word
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_pc
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_alu_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_br_en
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/exmem_rs2_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/execute/alumux1_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/execute/cmpmux_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/execute/alumux2_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/ex_alu_out
add wave -noupdate -group EX/MEM /mp4_tb/dut/datapath/ex_br_en
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_rst
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_load
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_instruction
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_ctrl_word
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_alu_out
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_rdata
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_br_en
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/memwb_pc
add wave -noupdate -group MEM/WB /mp4_tb/dut/datapath/wb_regfilemux_out
add wave -noupdate -group CPU-ICACHE /mp4_tb/dut/caches/icache_read
add wave -noupdate -group CPU-ICACHE /mp4_tb/dut/caches/icache_addr
add wave -noupdate -group CPU-ICACHE /mp4_tb/dut/caches/icache_rdata
add wave -noupdate -group CPU-ICACHE /mp4_tb/dut/caches/icache_resp
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_write
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_read
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_address
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_wdata
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_resp
add wave -noupdate -group ICACHE-ARB /mp4_tb/dut/caches/ipmem_rdata
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_write
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_read
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_address
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_wdata
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_resp
add wave -noupdate -group DCACHE-ARB /mp4_tb/dut/caches/dpmem_rdata
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_write
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_read
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_address
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_wdata
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_resp
add wave -noupdate -group ARB-CA /mp4_tb/dut/caches/apmem_rdata
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_read
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_write
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_address
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_wdata
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_rdata
add wave -noupdate -group CA-MEM /mp4_tb/dut/caches/pmem_resp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {320989 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 360
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1170750 ps}
