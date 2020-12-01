#!/bin/bash

binaries=`find . \( -path ./rootfs -o -path ./benchspec \) -prune -false -o -iname "*dev-r194673*aarch64"`

for binary in $binaries
do
    pushd . > /dev/null
	directory=`dirname $binary`
    file=`basename $binary`
    bench=`dirname ${directory}`
    echo "Processing ${bench} : ${file}"
    cd $directory
    rm *.funmap
	rm *.sqlite
    ~/workspace/nvcpu/dev/cpu/perf/tools/workgen/2.0/utils/gen_funmap.py --bin ./${file}
 	~/workspace/nvcpu/dev/cpu/perf/tools/workgen/2.0/utils/gen_src_db.py --bin ./${file} --src_dir ../../../../../src/v1.1.0/${bench}
	popd > /dev/null
done
