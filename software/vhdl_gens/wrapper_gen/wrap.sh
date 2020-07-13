#!/bin/bash

#Declare an array of excluded files
declare -a exf=(
		"kazio.vhd"
		"dupa.vhd"
		"cycki.vhd"
		)

start_dir=$1
output_dir=$2

export start_dir
export output_dir

echo "Starting directory: $start_dir"
echo "Output directory: $output_dir"
mkdir -p $output_dir
echo "----------------------------------------"

# now loop through the array of excluded files and create list of files for wrapping
tmp="-name *.vhd"
for i in "${exf[@]}"
do
	tmp=$tmp" -a -not -name "$i" "
done

#execute wrapper script
find $start_dir -type f $tmp \
-exec bash -c './wrapper_gen {} $output_dir/$(basename {} .vhd)_wrapper.vhd' \;

unset start_dir
unset output_dir
