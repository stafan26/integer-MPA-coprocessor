#
# Created by Kamil Rudnicki for use with Vivado v2017.3
#
# new_project_core.tcl: Tcl script for re-creating project 'core'
#
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
#*****************************************************************************************

# Determine the absolute path of the script
set scripts_abs_path [file normalize [file join [file dirname [info script]]]]

#*****************************************************************************************
# General sets

# Set name of new project.
set project_name core_looper
set part_number em.avnet.com:zed:part0:1.3
set board_name zedboard

set old_dir old

# Set the root directory of repository
set repo_root_dir "${scripts_abs_path}/../.."

# Set the root directory of data
set data_dir "${repo_root_dir}/data"

# Set the root directory of scripts
set script_dir "${repo_root_dir}/firmware/scripts"

# Set path to the project specific source hdl files
set core_src_hdl_dir "${repo_root_dir}/firmware/src/blocks/core"
set main_src_hdl_dir "${repo_root_dir}/firmware/src/blocks/${project_name}"

# Set path to the project specific source data files
set data_src_dir "${repo_root_dir}/data"

# Set path to the ip directory
set common_src_hdl_dir "${repo_root_dir}/firmware/src/common"

#*****************************************************************************************

# Set path to the vivado workspace
set vivado_dir "${repo_root_dir}/firmware/synth/blocks"

# Create a directory for vivado project
if {[file exists ${vivado_dir}] == 0} {
	exec mkdir -p ${vivado_dir}
}

# Get current date and time
set current_date [clock format [clock seconds] -format %Y_%m_%d_%Hh%M]
# Create a directory for current project
if {[file exists ${vivado_dir}/${project_name}_${board_name}] != 0} {
	# Create a directory for old vivado projects
	if {[file exists ${vivado_dir}/${old_dir}] == 0} {
		exec mkdir ${vivado_dir}/${old_dir}
	}
	exec mv ${vivado_dir}/${project_name}_${board_name} ${vivado_dir}/${old_dir}/${project_name}_${board_name}_${current_date}
	puts "${vivado_dir}/${project_name}_${board_name} already found and moved to ${vivado_dir}/${old_dir}/${project_name}_${board_name}_${current_date}"
}

exec mkdir ${vivado_dir}/${project_name}_${board_name}

# Create project
create_project ${project_name} ${vivado_dir}/${project_name}_${board_name}

## Switch off hirarchy updates
#set property source_mgmt_more None [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects ${project_name}]
set_property "board_part" $part_number $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj



	####################################
	###   SYNTHESIS  &  SIMULATION   ###
	####################################

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

source ${script_dir}/_core.tcl

# Add all required vhdl files for synthesis to this list
set files [list \
 "[file normalize "${main_src_hdl_dir}/parts/axis_fifo_gear_down.vhd"]"\
 "[file normalize "${main_src_hdl_dir}/parts/axis_fifo_gear_up.vhd"]"\
 "[file normalize "${main_src_hdl_dir}/parts/prog_loader.vhd"]"\
 "[file normalize "${main_src_hdl_dir}/core_looper.vhd"]"\
]

add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
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



	###########################
	###   SYNTHESIS  ONLY   ###
	###########################

set files [list \
 "[file normalize "${common_src_hdl_dir}/others/my_pll.vhd"]"\
 "[file normalize "${main_src_hdl_dir}/${project_name}_wrapper.vhd"]"\
]

add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
foreach file $files {
	set file [file normalize $file]
	set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
	set_property -name "is_enabled" -value "1" -objects $file_obj
	set_property -name "is_global_include" -value "0" -objects $file_obj
	set_property -name "library" -value "xil_defaultlib" -objects $file_obj
	set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
	set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
	set_property -name "used_in_simulation" -value "0" -objects $file_obj
	set_property -name "used_in_synthesis" -value "1" -objects $file_obj
}

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" ${project_name}_wrapper $obj



	###########################
	###   SIMULATION ONLY   ###
	###########################

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
current_fileset -simset [ get_filesets sim_1 ]

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Add all required vhdl files for synthesis to this list
set files [list \
 "[file normalize "${main_src_hdl_dir}/data/core_looper.mem"]"\
\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_data.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_prog.vhd"]"\
 "[file normalize "${common_src_hdl_dir}/sim/forcer_result.vhd"]"\
\
 "[file normalize "${core_src_hdl_dir}/TB/core_TB.vhd"]"\
 "[file normalize "${core_src_hdl_dir}/TB/core_TB_behav.wcfg"]"\
 "[file normalize "${main_src_hdl_dir}/TB/${project_name}_TB.vhd"]"\
 "[file normalize "${main_src_hdl_dir}/TB/${project_name}_TB_behav.wcfg"]"\
]

add_files -norecurse -fileset $obj $files

# Set 'source' fileset file properties for remote files
foreach file $files {
	set file [file normalize $file]
	set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
	set_property -name "is_enabled" -value "1" -objects $file_obj
	set_property -name "is_global_include" -value "0" -objects $file_obj
	set_property -name "library" -value "xil_defaultlib" -objects $file_obj
	set_property -name "path_mode" -value "RelativeFirst" -objects $file_obj
	set_property -name "used_in" -value "simulation" -objects $file_obj
}

set obj [get_filesets sim_1]
set_property -name "32bit" -value "0" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "incremental" -value "1" -objects $obj
set_property -name "nl.cell" -value "" -objects $obj
set_property -name "nl.incl_unisim_models" -value "0" -objects $obj
set_property -name "nl.process_corner" -value "slow" -objects $obj
set_property -name "nl.rename_top" -value "" -objects $obj
set_property -name "nl.sdf_anno" -value "1" -objects $obj
set_property -name "nl.write_all_overrides" -value "0" -objects $obj
set_property -name "source_set" -value "sources_1" -objects $obj
set_property -name "top" -value "core_looper_TB" -objects $obj
set_property -name "transport_int_delay" -value "0" -objects $obj
set_property -name "transport_path_delay" -value "0" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "xelab.dll" -value "0" -objects $obj
set_property -name "xsim.compile.tcl.pre" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvhdl.relax" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvlog.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.debug_level" -value "all" -objects $obj
set_property -name "xsim.elaborate.load_glbl" -value "1" -objects $obj
set_property -name "xsim.elaborate.mt_level" -value "auto" -objects $obj
set_property -name "xsim.elaborate.rangecheck" -value "0" -objects $obj
set_property -name "xsim.elaborate.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.sdf_delay" -value "sdfmax" -objects $obj
set_property -name "xsim.elaborate.snapshot" -value "" -objects $obj
set_property -name "xsim.elaborate.xelab.more_options" -value "" -objects $obj
set_property -name "xsim.simulate.custom_tcl" -value "" -objects $obj
set_property -name "xsim.simulate.log_all_signals" -value "1" -objects $obj
set_property -name "xsim.simulate.runtime" -value "20us" -objects $obj
set_property -name "xsim.simulate.saif" -value "" -objects $obj
set_property -name "xsim.simulate.saif_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.saif_scope" -value "" -objects $obj
set_property -name "xsim.simulate.tcl.post" -value "" -objects $obj
set_property -name "xsim.simulate.wdb" -value "" -objects $obj
set_property -name "xsim.simulate.xsim.more_options" -value "" -objects $obj

set_property generic "g_data_dir_path=$data_dir" [get_filesets sim_1]

set obj [get_filesets sim_1]
set_property "top" ${project_name}_TB $obj
update_compile_order -fileset sim_1


	################################
	###   PROGRAMS COMPILATION   ###
	################################

# compile all programs
set savedDir [pwd]
cd ${repo_root_dir}/software/
exec /bin/bash ./compile_all_programs.sh
cd $savedDir


	###############################
	###   SIMULATION DPI ONLY   ###
	###############################

# Create 'sim_dpi' fileset (if not found)
if {[string equal [get_filesets -quiet sim_dpi] ""]} {
  create_fileset -simset sim_dpi
}
current_fileset -simset [ get_filesets sim_dpi ]

source ${script_dir}/_core_dpi.tcl

set obj [get_filesets sim_dpi]
set_property "top" multiplier_dpi_TB $obj
update_compile_order -fileset sim_dpi



	####################
	###   CLEAN UP   ###
	####################

current_fileset -simset [ get_filesets sim_1 ]



	#######################
	###   CONSTRAINTS   ###
	#######################

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set files [list \
 "[file normalize "${core_src_hdl_dir}/core.xdc"]" \
 "[file normalize "${main_src_hdl_dir}/${project_name}.xdc"]" \
]

add_files -norecurse -fileset $obj $files

puts "INFO: Project created: ${project_name}"
set_property vhdl_version vhdl_93 [current_fileset]

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_EarlyBlockPlacement [get_runs impl_1]

set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
