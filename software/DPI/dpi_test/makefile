# Makefile for DPI functions
CC = /edatools/Xilinx/Vivado/2017.3/bin/xsc
COMPILED_LIB_PATH=$(shell pwd)/../../../firmware/sim/lib
COMMON_PATH=$(shell pwd)/../../common
MAKEFILE_PATH=$(shell pwd)
GMP_INC_PATH=/usr/include/x86_64-linux-gnu
GMP_LIB_PATH=/usr/lib/libgmp.so
SRC_FILENAME=dpi_test
SRC_LFSR_FILENAME=lfsr
TMP_DIR_PATH=$(shell pwd)/xsim.dir/xsc

.PHONY: default all clean

default: $(COMPILED_LIB_PATH)/$(SRC_FILENAME).o
all: default

$(COMPILED_LIB_PATH)/$(SRC_FILENAME).o: $(TMP_DIR_PATH)/$(SRC_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o
	@echo "CC=$(CC)"
	@echo "COMPILED_LIB_PATH=$(COMPILED_LIB_PATH)"
	@echo "MAKEFILE_PATH=$(MAKEFILE_PATH)"
	@echo "GMP_INC_PATH=$(GMP_INC_PATH)"
	@echo "GMP_LIB_PATH=$(GMP_LIB_PATH)"
	@echo
	@echo "=========================== Linking of output files ==========================="
	libtool --tag=CC --mode=link cc -static -o $(COMPILED_LIB_PATH)/$(SRC_FILENAME).o $(TMP_DIR_PATH)/$(SRC_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o $(GMP_LIB_PATH)
	mv $(COMPILED_LIB_PATH)/$(SRC_FILENAME).o $(COMPILED_LIB_PATH)/$(SRC_FILENAME).so

$(TMP_DIR_PATH)/$(SRC_FILENAME).lnx64.o: $(SRC_FILENAME).c $(SRC_FILENAME).h
	@echo
	@echo "========================== Compilation of $(SRC_FILENAME).c ========================="
	$(CC) --compile $(SRC_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

$(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o: $(COMMON_PATH)/$(SRC_LFSR_FILENAME).c $(COMMON_PATH)/$(SRC_LFSR_FILENAME).h
	@echo
	@echo "============================ Compilation of $(SRC_LFSR_FILENAME).c ============================"
	$(CC) --compile $(COMMON_PATH)/$(SRC_LFSR_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

clean:
	-rm -f *.log
	-rm -f *.pb
	-rm -rf xsim.dir
	-rm -f $(COMPILED_LIB_PATH)/$(SRC_FILENAME).so
