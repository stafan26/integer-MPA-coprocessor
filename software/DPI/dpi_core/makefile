# Makefile for DPI functions
CC = /edatools/Xilinx/Vivado/2018.3/bin/xsc
COMPILED_LIB_PATH=$(shell pwd)/../../../firmware/sim/lib
MAKEFILE_PATH=$(shell pwd)
EMUSRUP_PATH=$(shell pwd)/../../emusrup
COMMON_PATH=$(shell pwd)/../../common
GMP_INC_PATH=/usr/include/x86_64-linux-gnu
GMP_LIB_PATH=/usr/lib/libgmp.so
SRC_EMU_FILENAME=emusrup
SRC_TM_FILENAME=time_maker
SRC_LFSR_FILENAME=lfsr
SRC_WRF_FILENAME=write_fun
SRC_RDF_FILENAME=read_fun
OUT_FILENAME=dpi_core
TMP_DIR_PATH=$(shell pwd)/xsim.dir/xsc

.PHONY: default all clean

default: $(COMPILED_LIB_PATH)/$(OUT_FILENAME).o
all: default

$(COMPILED_LIB_PATH)/$(OUT_FILENAME).o: $(TMP_DIR_PATH)/$(SRC_EMU_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_TM_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_WRF_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_RDF_FILENAME).lnx64.o
	@echo "CC=$(CC)"
	@echo "COMPILED_LIB_PATH=$(COMPILED_LIB_PATH)"
	@echo "MAKEFILE_PATH=$(MAKEFILE_PATH)"
	@echo "EMUSRUP_PATH=$(EMUSRUP_PATH)"
	@echo "COMMON_PATH=$(COMMON_PATH)"
	@echo "GMP_INC_PATH=$(GMP_INC_PATH)"
	@echo "GMP_LIB_PATH=$(GMP_LIB_PATH)"
	@echo
	@echo "=========================== Linking of output files ==========================="
	libtool --tag=CC --mode=link cc -static -o $(COMPILED_LIB_PATH)/$(OUT_FILENAME).o $(TMP_DIR_PATH)/$(SRC_EMU_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_TM_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_WRF_FILENAME).lnx64.o $(TMP_DIR_PATH)/$(SRC_RDF_FILENAME).lnx64.o $(GMP_LIB_PATH)
	mv $(COMPILED_LIB_PATH)/$(OUT_FILENAME).o $(COMPILED_LIB_PATH)/$(OUT_FILENAME).so

$(TMP_DIR_PATH)/$(SRC_EMU_FILENAME).lnx64.o: $(EMUSRUP_PATH)/$(SRC_EMU_FILENAME).c $(EMUSRUP_PATH)/$(SRC_EMU_FILENAME).h
	@echo
	@echo "=========================== Compilation of $(SRC_EMU_FILENAME).c =========================="
	$(CC) --compile $(EMUSRUP_PATH)/$(SRC_EMU_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

$(TMP_DIR_PATH)/$(SRC_TM_FILENAME).lnx64.o: $(EMUSRUP_PATH)/$(SRC_TM_FILENAME).c $(EMUSRUP_PATH)/$(SRC_TM_FILENAME).h
	@echo
	@echo "========================= Compilation of $(SRC_TM_FILENAME).c ========================="
	$(CC) --compile $(EMUSRUP_PATH)/$(SRC_TM_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

$(TMP_DIR_PATH)/$(SRC_LFSR_FILENAME).lnx64.o: $(COMMON_PATH)/$(SRC_LFSR_FILENAME).c $(COMMON_PATH)/$(SRC_LFSR_FILENAME).h
	@echo
	@echo "============================ Compilation of $(SRC_LFSR_FILENAME).c ============================"
	$(CC) --compile $(COMMON_PATH)/$(SRC_LFSR_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

$(TMP_DIR_PATH)/$(SRC_WRF_FILENAME).lnx64.o: $(COMMON_PATH)/$(SRC_WRF_FILENAME).c $(COMMON_PATH)/$(SRC_WRF_FILENAME).h
	@echo
	@echo "============================ Compilation of $(SRC_WRF_FILENAME).c ============================"
	$(CC) --compile $(COMMON_PATH)/$(SRC_WRF_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

$(TMP_DIR_PATH)/$(SRC_RDF_FILENAME).lnx64.o: $(COMMON_PATH)/$(SRC_RDF_FILENAME).c $(COMMON_PATH)/$(SRC_RDF_FILENAME).h
	@echo
	@echo "============================ Compilation of $(SRC_RDF_FILENAME).c ============================"
	$(CC) --compile $(COMMON_PATH)/$(SRC_RDF_FILENAME).c --additional_option -I$(GMP_INC_PATH) -work ./ -v 1

clean:
	-rm -f *.log
	-rm -f *.pb
	-rm -rf xsim.dir
	-rm -f $(COMPILED_LIB_PATH)/$(OUT_FILENAME).so
