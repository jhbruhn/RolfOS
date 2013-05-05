NASMARGS = -f bin -O0 -I source/
COLOR_END = "\\033[0m"
COLOR_START = "\\033[31m"
UNAME := $(shell uname)

all: floppy
	
compile: clean
	@echo "$(COLOR_START)>> Compiling binaries...$(COLOR_END)"
	mkdir -p binaries
	$(foreach name, $(wildcard source/*.asm),  nasm $(NASMARGS) $(name) -o binaries/$(shell basename $(name) .asm).bin;)
	@echo "$(COLOR_START)>> Compiled!$(COLOR_END)"
	
clean: 
	@echo "$(COLOR_START)>> Removing dirs...$(COLOR_END)"
	rm -rf binaries/ disks/ iso-tmp/ loop-tmp/
	rm -f rolfOS.iso
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"

floppy: compile
	@echo "$(COLOR_START)>> Creating floppy...$(COLOR_END)"
	mkdir -p disks
	dd if=/dev/zero of=disks/rolfOS.flp bs=1k count=1440
	dd conv=notrunc if=binaries/bootload.bin of=disks/rolfOS.flp
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"
	
	@echo "$(COLOR_START)>> Copying files to floppy...$(COLOR_END)"
	@if [ "$(UNAME)" == "Darwin" ]; then \
		cp disks/rolfOS.flp disks/rolfOS.dmg; \
		export MOUNTED_FILE=$$(hdid -nobrowse -nomount disks/rolfOS.dmg); \
		mkdir loop-tmp; \
		mount -t msdos $$(echo $$MOUNTED_FILE) loop-tmp; \
		cp binaries/*.bin loop-tmp/; \
		sleep 0.2; \
		umount loop-tmp; \
		hdiutil detach $$(echo $$MOUNTED_FILE); \
		rm -rf loop-tmp; \
		rm disks/rolfOS.flp; \
		cp disks/rolfOS.dmg disks/rolfOS.flp; \
		rm disks/rolfOS.dmg; \
	else \
		mkdir tmp-loop; \
		mount -o loop -t vfat disks/rolfOS.flp tmp-loop; \
		cp binaries/*.bin loop-tmp/; \
		sleep 0.2; \
		umount tmp-loop; \
		rm -rf tmp-loop; \
	fi
	@echo "$(COLOR_START)>> Done!"

iso: floppy
	@echo "$(COLOR_START)>> Converting floppy to iso...$(COLOR_END)"
	mkisofs -quiet -V 'ROLFOS' -input-charset iso8859-1 -o disks/rolfOS.iso -b rolfOS.flp disks/
	rm -rf iso-tmp
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"
	
run: runfloppy
	
runfloppy: floppy
	@echo "$(COLOR_START)>> Starting QEMU i386 with floppyimage as floppy...$(COLOR_END)"
	qemu-system-i386 -soundhw pcspk -fda disks/rolfOS.flp
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"
	
runhdd: floppy
	@echo "$(COLOR_START)>> Starting QEMU i386 with floppyimage as hdd...$(COLOR_END)"
	qemu-system-i386 -hda disks/rolfOS.flp
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"

runiso: iso
	@echo "$(COLOR_START)>> Starting QEMU i386 with iso as cd...$(COLOR_END)"
	qemu-system-i386 -cdrom rolfOS.iso
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"