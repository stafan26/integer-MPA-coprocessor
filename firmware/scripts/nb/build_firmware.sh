#!/bin/bash

#initial setup
DATE=`date '+%Y%m%d-%H%M-'`

ABS_REPO_PATH="$( cd "$(dirname "$0")" ; cd ../../../ ; pwd -P )"
echo "Absolute repo path: $ABS_REPO_PATH"

FIRMWARE_REPO_PATH=$ABS_REPO_PATH"/firmware"
SCRIPTS_REPO_PATH=$FIRMWARE_REPO_PATH"/scripts"
NB_REPO_PATH=$SCRIPTS_REPO_PATH"/nb"

BRANCH=$1
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "$CURRENT_BRANCH" ]
then
	echo "Go to branch: $BRANCH"
	git checkout $BRANCH
else
	echo "Already on branch: $BRANCH"
fi

PROJ=$SCRIPTS_REPO_PATH"/new_project_"$2".tcl"
echo "Open project: $PROJ"

MAX_PATHS=$3
echo "Max number of analyzed paths: $MAX_PATHS"

REPORT_FILE_NAME=$NB_REPO_PATH"/$DATE$2_report_design_analysis.txt"
echo "Report of design analysis: $REPORT_FILE_NAME"

TIMING_FILE_NAME=$NB_REPO_PATH"/$DATE$2_report_timing_analysis.txt"
echo "Report of timing analysis: $TIMING_FILE_NAME"

CONCAT_FILE_NAME=$NB_REPO_PATH"/$DATE$2_report.txt"
echo "Concatenated report of analysis: $CONCAT_FILE_NAME"

SAVE_DIR=$ABS_REPO_PATH"/reports/nb"
SYNTH_SCRIPT=$NB_REPO_PATH"/synthesize.tcl"
SUMMARY_FILE_NAME="$SAVE_DIR/summary.txt"

#execute vivado
vivado -mode tcl -source $SYNTH_SCRIPT -tclargs $PROJ $MAX_PATHS $REPORT_FILE_NAME

#copy timing report
SEARCH_PATH=$FIRMWARE_REPO_PATH"/synth/blocks/"$2
OUTPUT_PATH=$(find $SEARCH_PATH -name "*timing_summary_postroute_physopted.rpt")

if [ -z "$OUTPUT_PATH" ]
then
      echo "File of timing_summary_postroute_physopted is empty"
      OUTPUT_PATH=$(find $SEARCH_PATH -name "*timing_summary_routed.rpt")
else
      echo "File of timing_summary_postroute_physopted is NOT empty"
fi
echo "Copied file of timing_analysis: $OUTPUT_PATH"
cp $OUTPUT_PATH $TIMING_FILE_NAME
cat $REPORT_FILE_NAME $TIMING_FILE_NAME >> $CONCAT_FILE_NAME

if [ ! -d "$SAVE_DIR" ]; then
	# Control will enter here if $SAVE_DIR doesn't exist.
	mkdir -p $SAVE_DIR
fi
cp $CONCAT_FILE_NAME $SAVE_DIR

#add info to summary file
$NB_REPO_PATH"/summary_report_add_line" $TIMING_FILE_NAME $SUMMARY_FILE_NAME
printf "   %s\n" "$2" >> $SUMMARY_FILE_NAME

#clean directory
rm -f vivado*.jou
rm -f vivado*.log

rm -rf $REPORT_FILE_NAME
rm -rf $TIMING_FILE_NAME
rm -rf $CONCAT_FILE_NAME


