#!/bin/bash

THIS_SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

ABS_REPO_PATH="$( cd "$(dirname "$0")" ; cd ../../../ ; pwd -P )"
SAVE_DIR=$ABS_REPO_PATH"/reports/nb"
SUMMARY_FILE_NAME="$SAVE_DIR/summary.txt"
$THIS_SCRIPT_PATH"/summary_report_add_header.sh" $SUMMARY_FILE_NAME

xargs < $THIS_SCRIPT_PATH"/build_firmware_list.txt" -n 3 $THIS_SCRIPT_PATH"/build_firmware.sh"
#       ^               ^   ^
#       |               |   Command to run
#       |               Max number of arguments (build_firmware.sh will be called for
#       |               each line in input file)
#       Input file
