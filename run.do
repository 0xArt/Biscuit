quit -sim
.main clear

file delete -force presynth
vlib presynth
vmap presynth presynth


vlog -sv -work presynth \
    "rtl/block_ram/generic_block_ram.sv" \
    "rtl/block_ram/block_ram.sv" \
    "rtl/riscv_constants_package.sv" \
    "rtl/single_cycle/riscv_alu.sv" \
    "rtl/single_cycle/riscv_instruction_decoder.sv" \
    "rtl/single_cycle/riscv_memory_writer.sv" \
    "rtl/single_cycle/riscv_memory.sv" \
    "rtl/single_cycle/riscv_register_file.sv" \
    "rtl/single_cycle/riscv_program_counter.sv" \
    "rtl/single_cycle/riscv_write_back_controller.sv" \
    "rtl/single_cycle/riscv_memory_reader.sv" \
    "rtl/single_cycle/riscv_core.sv" \
    "rtl/pipelined/fetch_stage.sv" \
    "rtl/pipelined/decode_stage.sv" \
    "rtl/pipelined/execute_stage.sv" \
    "rtl/pipelined/memory_stage.sv" \
    "rtl/pipelined/write_back_stage.sv" \
    "rtl/pipelined/register_status_table.sv" \
    "rtl/pipelined/base_branch_predictor.sv" \
    "rtl/pipelined/branch_manager.sv" \
    "rtl/pipelined/riscv_core_pipelined.sv" \
    "test/testbench.sv"

vsim -voptargs=+acc -L presynth -work presynth -t 1ps presynth.testbench
add log -r /*

if {[file exists "wave.do"]} {
    do  "wave.do"
}

run -all