#!/bin/bash
FILE="tmp.txt"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NUM_OF_ARCH=$(cat $1 | grep -i "architecture.* is" | wc -l)
csplit --digits=1 --quiet --prefix=${1}-autogen-outfile_ ${1} "/architecture.*is/+1" "{*}"

for (( i=0; i<NUM_OF_ARCH; i++ )); do
	cat ${1}-autogen-outfile_$i\
	| sed -e 's/--.*//g' \
	| awk -f $DIR/script.awk > $FILE
	echo "File sent to: $FILE"
	#geany $FILE
	#rm $FILE
done

rm ${1}-autogen-outfile_*
