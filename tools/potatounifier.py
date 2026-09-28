#!/usr/bin/env python3

files = ["boot/boot.bin", "kernel/kernel.bin"]
image_file = "potatos.img"

with open(image_file, "wb") as image:
	for file_name in files:
		with open(file_name, "rb") as file:
			file_data = file.read()

		file_size = len(file_data)
		spare = file_size % 512

		if spare != 0:
			calc_size = ((file_size // 512) + 1) * 512

			zero_completer = b'\x00' * (calc_size - file_size)

			file_data += zero_completer

		image.write(file_data)
