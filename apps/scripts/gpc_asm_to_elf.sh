# Compile C source
GNU_DIR=/home/adlv/projects/riscv/install/rv32i/bin/
 #link new ams file with gpc initializer and creates elf file
$GNU_DIR/riscv32-unknown-elf-gcc  -O3  -march=rv32i -mabi=ilp32  \
  -Wextra -Wall \
-Wno-unused-parameter -Wno-unused-variable -Wno-unused-function \
-fdata-sections -ffunction-sections -fdiagnostics-color=always  \
-T$GNU_DIR/dom_link.common.ld -nostartfiles -Wl,--gc-sections \
-D__riscv__ \
$1.c.s \
$GNU_DIR/crt0_gpc.S  \
-o $1.elf
#creates readable elf file
$GNU_DIR/riscv32-unknown-elf-objdump -gd $1.elf > $1_elf.txt
#creates the instruction file 
$GNU_DIR/riscv32-unknown-elf-objcopy --srec-len 1 --output-target=verilog $1.elf $1_inst_mem.sv 
