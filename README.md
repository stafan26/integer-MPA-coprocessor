# Integer-MPA-Coprocessor
Open-Source Coprocessor for Integer Multiple Precision Arithmetic

##### Programming language: VHDL/C/C++/SystemVerilog

---
## Introduction
The purpose of the project is to develop the VHDL code for FPGA allowing to accelerate MPA computations. The developed device should work as a coprocessor for standard CPU. As a starting point, the basic arithmetic operations are chosen for implementation in FPGA, i.e., addition, subtraction, multiplication. The device should support the integer operations based thesign-magnitude representation of data (i.e., it should be similar to the GMP standard).

## Scientific work
If the code is used in a scientific work, then **reference should be made to the following publication**:

K. Rudnicki, T. P. Stefanski, W. Zebrowski, "Open-Source Coprocessor for Integer Multiple Precision Arithmetic," Electronics, MDPI, 2020.

This publication also includes the description of the coprocessor architecture.

---
## Manual

## Authors
The project is developed by

Kamil Rudnicki - VHDL codes, firmware development

Tomasz Stefanski - C/C++ codes, software development

Wojciech Zebrowski - Implementation on TySOM-1 board, evaluation and benchmarking

## License
This is an open-source code licensed under the [Mozilla license](LICENSE).
