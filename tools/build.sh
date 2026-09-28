#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "Building..."

# Boot
nasm -f bin boot/boot.asm -o boot/boot.bin

# Kernel
nasm -f bin kernel/kernel.asm -o kernel/kernel.bin

# Image
python3 tools/potatounifier.py

echo "Done."

executer_pro_max() {
	read -p "Run PotatOS image? (Y/n): " execute

	if [ ${execute,,} == "y" ]; then
		echo "Running PotatOS..."
		qemu-system-i386 -drive format=raw,file=potatos.img,if=floppy
		exit 0

	elif [ ${execute,,} == "n" ]; then
		echo "Operation complete."
		exit 0
	else
		echo "Write it again, better"
		executer_pro_max
	fi
}

executer_pro_max
