	################
	###   CORE   ###
	################

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Add all required vhdl files for synthesis to this list
set files [list \
 "[file normalize "${common_src_hdl_dir}/packs/pro_pack.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/packs/my_pack.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/packs/common_pack.vhd"]"\
\
 "[file normalize "${common_src_hdl_dir}/operations/add_64.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/add_sub_64.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/sub_64.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/mult_64.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/incr_decr_64_wo_cout.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/incr_64_wo_cout.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/operations/decr_64_wo_cout.vhd"]"\
\
 "[file normalize "${common_src_hdl_dir}/others/data_delayer.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/ff.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_16_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_8_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_5_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_4_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_2_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_1_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_auto_logic.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/mux_auto_phys.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/my_bram.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/oper_switchbox.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/or_ff.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/or_gate.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/switchbox_x2_extra.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/switchbox_x4_extra.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/others/switchbox_x4_last.vhd"]"\
\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down_3_last_1.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down_3_last_2_cas.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down_4_last_2.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down_5_last_2.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down_size_with_last.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_down.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_minus_one.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_minus_two.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_up_down_with_last.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_up_down_3_last.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_up.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/loader/loader.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/loader/loader_bay.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/loader/unloader.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/common/common_ctrl.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/common/common_switchbox.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/common/common.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/adder/adder_ctrl.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/adder/adder_carry_add_sub.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/adder/adder_carry_sub.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/adder/adder_data_ranger.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/adder/adder.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_acc_ip_64.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_carry_add.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_ctrl.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_cycle_cropper.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_diversion.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_mux.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_part_adder.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/mult_sync.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/multiplier/multiplier.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/register/reg_addressing_unit.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_address_selector.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_ctrl.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_selector.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_switchbox.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_driver.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_write_addr.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/reg_base.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/register/register_single.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_blocker.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_busybox.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cnt_last.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_switch.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_add_sub_data_last.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_add_sub.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_control_delay.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_cycler_ctrl.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_cycler.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_data_last.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_data_organizer.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult_size_converter.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_mult.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc_unload.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_cmc.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_mapper_swapper.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_mapper_swapper_a2m.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_mapper_swapper_m2a.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_mapper_reg.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_mapper.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_executer.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_peripheral_delayer.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_prefetch.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_follower_data_last_switchbox.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_follower_reg_observer.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu_follower.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/cpu/cpu.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/core.vhd"]"\
]

add_files -norecurse -fileset $obj $files

# Set 'source' fileset file properties for remote files
foreach file $files {
	set file [file normalize $file]
	set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
	set_property -name "is_enabled" -value "1" -objects $file_obj
	set_property -name "is_global_include" -value "0" -objects $file_obj
	set_property -name "library" -value "xil_defaultlib" -objects $file_obj
	set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
	set_property -name "used_in" -value "synthesis implementation simulation" -objects $file_obj
	set_property -name "used_in_simulation" -value "1" -objects $file_obj
	set_property -name "used_in_synthesis" -value "1" -objects $file_obj
}

set_property is_enabled false [get_files "[file normalize "${common_src_hdl_dir}/others/mux_8_1.vhd"]"]
set_property is_enabled false [get_files "[file normalize "${common_src_hdl_dir}/others/mux_2_1.vhd"]"]
set_property is_enabled false [get_files "[file normalize "${common_src_hdl_dir}/others/switchbox_x4_last.vhd"]"]
set_property is_enabled false [get_files "[file normalize "${common_src_hdl_dir}/counters/lfsr_counter_minus_two.vhd"]"]



