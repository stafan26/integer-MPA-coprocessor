# Integer-MPA-Coprocessor
Open-Source Coprocessor for Integer Multiple Precision Arithmetic

##### Programming language: VHDL/C/C++/SystemVerilog

[![Version](https://img.shields.io/badge/version-1.0-green.svg)](README.md) [![License](https://img.shields.io/badge/license-Mozilla-blue.svg)](https://opensource.org/licenses/MPL-2.0)

---
## Introduction
The purpose of the project is to develop the VHDL code for FPGA allowing to accelerate MPA computations. The developed device should work as a coprocessor for standard CPU. As a starting point, the basic arithmetic operations are chosen for implementation in FPGA, i.e., addition, subtraction, multiplication. The device should support the integer operations based thesign-magnitude representation of data (i.e., it should be similar to the GMP standard).

## Scientific work
If the code is used in a scientific work, then **reference should be made to the following publication**:

K. Rudnicki, T. P. Stefanski, W. Zebrowski, "Open-Source Coprocessor for Integer Multiple Precision Arithmetic," Electronics, MDPI, 2020.

This publication also includes the description of the coprocessor architecture and results of benchmarks. It also includes the scheme of implementation on TySOM-1 board from Aldec.

---
## Manual
Repository includes two main parts:
./firmware
./software

## Firmware
Firmware is grouped within the following directories:
- bd - this directory contains the general board files (for zedboard)
- scripts - this directory contains scripts for firmaware generation
- sim - this directory contains simulation files
- src - this directory contains source files

## Software
All software can be compiled with the use of the script: compile_all_programs.sh. Executable and object files can be removed with the use of the script: clean_all_programs.sh.

Software is grouped within the following directories:

- common - this directory contains useful functions used by all codes

- data_apps - this directory contains codes generating input files for the coprocessor
    * 1ddgf_data - this code generates files for computations of 1-D discrete Green's function
    * addition_data - this code tests adition in the coprocessor
    * factorial_data - this code generates files for computations of factorial
    * powernn_data - this code computes n^n
    * random_data - this code generates files for random computations on random data
    * progwriter - this code allows to generate the coprocessor code with the use of GUI

- DPI - this directory contains codes for DPI tests
    * dpi_module - this code allows us to test multiplication and addition in the coprocessor
    * dpi_core - this code allows to test the coprocessor core
    * dpi_test - this code allows us to test DPI interface

- emusrup - this code emulates the coprocessor with the use of GMP (i.e. EmuSRuP = "Emulate Stefanski Rudnicki MicroProcessor") 

- helpers - some useful and helpful codes
    * bin2coe - this code converts *.bin files into *.coe type
    * bin2mem - this code converts *.bin files into *.mem type
    * mult_regs_address - this code presents multiplication operation for multiple-precision numbers

- runtime - this directory contains codes executable on CPU for the coprocessor benchmarking
    * 1ddgf_runtime - this code computes 1-D discrete Green's function on CPU
    * factorial_runtime - this code computes factorial on CPU
    * pownn_runtime - this code computes n^n on CPU    
    * add - this code tests addition speed on CPU
    * div_vs_mult - this code allows one to compare division and multiplication

- vhdl_gens - this directory contains codes for vhdl generation
    * mux_gen - this code generates vhdl code of multiplexer
    * or_gen - this code generates or structure
    * wrapper_gen - this code generates vhdl wrapper

After compilation, one can check program arguments executing it without any argument.

## Authors
The project is developed by
- Kamil Rudnicki - VHDL codes, firmware development
- Tomasz Stefanski - C/C++ codes, software development
- Wojciech Zebrowski - Implementation on TySOM-1 board, evaluation and benchmarking

## License
This is an open-source code licensed under the [Mozilla license](LICENSE).
