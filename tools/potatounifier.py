#!/usr/bin/env python3

files = ["boot/boot.bin", "kernel/kernel.bin"]
image_file = "potatos.img"

with open(image_file, "wb") as image:
	for file_name in files:
		with open(file_name, "rb") as file:
			image.write(file.read())
