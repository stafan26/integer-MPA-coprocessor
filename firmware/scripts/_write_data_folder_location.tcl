#!/bin/env tclsh

set UPDATE_AUTOMATICALLY 1
set MANUALLY_SPECIFIED_FOLDER "Please change this line to the specific, valid data folder - absolute path"

set filename "dpi_core_data_folder_location.svh"
set output_file_relative_path "firmware/sim"
set data_relative_path "data"

#########   DO NOT EDIT BELOW THIS LINE   #########
set script_path [ file dirname [file normalize [ info script ] ] ]

set REPO_ROOT "$script_path/../.."

set DATA_LOCATION "$MANUALLY_SPECIFIED_FOLDER"
if {$UPDATE_AUTOMATICALLY} {
	set DATA_LOCATION "$REPO_ROOT/$data_relative_path"
}

set data "parameter string g_data_dir_path = \"[file normalize $DATA_LOCATION]\";\n"

puts stdout {}
puts stdout "   The location of the script for data folder update: [file normalize $script_path]"
puts stdout "   Repo location: [file normalize $REPO_ROOT]"
puts stdout "   Data folder used for simulation: [file normalize $DATA_LOCATION]"
if {$UPDATE_AUTOMATICALLY} {
	puts stdout {   Data folder auto-updated.}
} else {
	puts stdout {   Data folder specified manually.}
}
puts stdout {}

set fileId [open $REPO_ROOT/$output_file_relative_path/$filename "w"]
puts -nonewline $fileId $data
close $fileId
