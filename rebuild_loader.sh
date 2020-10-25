#!/bin/bash

if [ "$#" -ne 2 ]; 
    then echo "$0 </tmp/file.asm> </tmp/loader>"
    exit
fi

set -euo pipefail

tmp_dir=$(mktemp -d -t e17-XXXXXXXXXX)

cp $1 $tmp_dir/input.asm

cp *.asm $tmp_dir
cp *.inc $tmp_dir
cd $tmp_dir

echo "Removing section attributes from input file"
sed -ie '/^section/d' $tmp_dir/input.asm

echo "Building input file"
nasm -f elf64 -o $tmp_dir/input.o $tmp_dir/input.asm > /dev/null 2>&1
ld -o $tmp_dir/input $tmp_dir/input.o

echo "Building encrypter"
nasm -f bin -o $tmp_dir/enc $tmp_dir/enc.asm > /dev/null 2>&1
echo "Runing encrypter"
chmod +x $tmp_dir/enc
$tmp_dir/enc
echo "Building loader"
nasm -f bin -o $tmp_dir/loader $tmp_dir/loader.asm > /dev/null 2>&1
echo "Done"
cp $tmp_dir/loader $2

