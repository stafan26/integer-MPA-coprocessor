SCRIPT_PATH=${0%/*}

pushd $SCRIPT_PATH > /dev/null

find -type f \( -name 'GNUmakefile' -o -name 'makefile' -o -name 'Makefile' \) \
-exec bash -c 'cd "$(dirname "{}")" && make clean' \;

popd > /dev/null
