	####################
	###   DPI CORE   ###
	####################

# Set 'sim_dpi_core' fileset object
set obj [get_filesets sim_dpi_core]
# Add all required vhdl files for synthesis to this list
set files [list \
 "[file normalize "${repo_root_dir}/firmware/sim/dpi_core_data_folder_location.svh"]"\
 "[file normalize "${common_src_hdl_dir}/packs/test_pack.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_prog.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_data.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_result.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/TB/error_checker.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/TB/core_with_probes_and_checker.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/TB/core_dpi_TB.sv"]"\
 "[file normalize "${core_src_hdl_dir}/TB/core_dpi_TB_behav.wcfg"]"\
]

add_files -norecurse -fileset $obj $files

# Set 'sim_dpi_core' fileset file properties for remote files
foreach file $files {
	set file [file normalize $file]
	set file_obj [get_files -of_objects [get_filesets sim_dpi_core] [list "*$file"]]
	set_property -name "is_enabled" -value "1" -objects $file_obj
	set_property -name "is_global_include" -value "0" -objects $file_obj
	set_property -name "library" -value "xil_defaultlib" -objects $file_obj
	set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
	set_property -name "used_in" -value "simulation" -objects $file_obj
	set_property -name "used_in_simulation" -value "1" -objects $file_obj
}

#set obj [get_filesets sim_dpi_core]
#set_property -name "generic" -value "" -objects $obj
#set_property -name "include_dirs" -value "" -objects $obj
#set_property -name "incremental" -value "1" -objects $obj
#set_property -name "nl.cell" -value "" -objects $obj
#set_property -name "nl.incl_unisim_models" -value "0" -objects $obj
#set_property -name "nl.process_corner" -value "slow" -objects $obj
#set_property -name "nl.rename_top" -value "" -objects $obj
#set_property -name "nl.sdf_anno" -value "1" -objects $obj
#set_property -name "nl.write_all_overrides" -value "0" -objects $obj
#set_property -name "source_set" -value "sources_1" -objects $obj
#set_property -name "top" -value "multiplier_dpi_TB" -objects $obj
#set_property -name "transport_int_delay" -value "0" -objects $obj
#set_property -name "transport_path_delay" -value "0" -objects $obj
#set_property -name "verilog_define" -value "" -objects $obj
#set_property -name "verilog_uppercase" -value "0" -objects $obj
#set_property -name "xelab.dll" -value "0" -objects $obj
#set_property -name "xsim.compile.tcl.pre" -value "" -objects $obj
#set_property -name "xsim.compile.xvhdl.more_options" -value "" -objects $obj
#set_property -name "xsim.compile.xvhdl.nosort" -value "1" -objects $obj
#set_property -name "xsim.compile.xvhdl.relax" -value "1" -objects $obj
#set_property -name "xsim.compile.xvlog.more_options" -value "" -objects $obj
#set_property -name "xsim.compile.xvlog.nosort" -value "1" -objects $obj
#set_property -name "xsim.compile.xvlog.relax" -value "1" -objects $obj
#set_property -name "xsim.elaborate.debug_level" -value "all" -objects $obj
set_property -name "xsim.elaborate.load_glbl" -value "0" -objects $obj
#set_property -name "xsim.elaborate.mt_level" -value "auto" -objects $obj
#set_property -name "xsim.elaborate.rangecheck" -value "0" -objects $obj
#set_property -name "xsim.elaborate.relax" -value "1" -objects $obj
#set_property -name "xsim.elaborate.sdf_delay" -value "sdfmax" -objects $obj
#set_property -name "xsim.elaborate.snapshot" -value "" -objects $obj
set_property -name "xsim.elaborate.xelab.more_options" -value "-sv_lib dpi_core -sv_root ${repo_root_dir}/firmware/sim/lib/ -trace_limit 1048576" -objects $obj
#set_property -name "xsim.simulate.custom_tcl" -value "" -objects $obj
#set_property -name "xsim.simulate.log_all_signals" -value "1" -objects $obj
#set_property -name "xsim.simulate.runtime" -value "20us" -objects $obj
#set_property -name "xsim.simulate.saif" -value "" -objects $obj
#set_property -name "xsim.simulate.saif_all_signals" -value "0" -objects $obj
#set_property -name "xsim.simulate.saif_scope" -value "" -objects $obj
#set_property -name "xsim.simulate.tcl.post" -value "" -objects $obj
#set_property -name "xsim.simulate.wdb" -value "" -objects $obj
#set_property -name "xsim.simulate.xsim.more_options" -value "" -objects $obj


set_property file_type {VHDL 2008} [get_files "[file normalize "${core_src_hdl_dir}/TB/core_with_probes_and_checker.vhd"]"]
update_compile_order -fileset sim_dpi_core
