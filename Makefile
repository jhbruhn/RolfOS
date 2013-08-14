NASMARGS = -f bin -O0
COLOR_END = "\\033[0m"
COLOR_START = "\\033[31m"
UNAME := $(shell uname)

all: floppy
	
compilebootloader:
	@echo "$(COLOR_START)>> Compiling bootloader...$(COLOR_END)"
	
	mkdir -p binaries/
	
	nasm $(NASMARGS) source/bootload.asm -o binaries/bootload.bin
	
	@echo "$(COLOR_START)>> Compiled!$(COLOR_END)"
	
compilekernel:
	@echo "$(COLOR_START)>> Compiling kernel...$(COLOR_END)"
	
	mkdir -p binaries/
	
	nasm $(NASMARGS) -I source/ source/kernel.asm -o binaries/kernel.bin
	
	@echo "$(COLOR_START)>> Compiled!$(COLOR_END)"
	
compileprograms:
	@echo "$(COLOR_START)>> Compiling programs...$(COLOR_END)"
	
	mkdir -p binaries/
	
	$(foreach name, $(wildcard source/programs/*.asm),  nasm $(NASMARGS) -I source/programs/ $(name) -o binaries/$(shell basename $(name) .asm).rex;)
	
	@echo "$(COLOR_START)>> Compiled!$(COLOR_END)"
	
	
compile: clean compilekernel compilebootloader compileprograms
	
clean: 
	@echo "$(COLOR_START)>> Removing dirs...$(COLOR_END)"
	rm -rf binaries/ disks/ iso-tmp/ loop-tmp/
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"

floppy: compile
	@echo "$(COLOR_START)>> Creating floppy...$(COLOR_END)"
	mkdir -p disks
	dd if=/dev/zero of=disks/rolfOS.flp bs=1k count=1440 > /dev/null 2>&1
	dd conv=notrunc if=binaries/bootload.bin of=disks/rolfOS.flp > /dev/null 2>&1
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"
	
	@echo "$(COLOR_START)>> Copying files to floppy...$(COLOR_END)"
	@if [ "$(UNAME)" == "Darwin" ]; then \
		cp disks/rolfOS.flp disks/rolfOS.dmg; \
		export MOUNTED_FILE=$$(hdid -nobrowse -nomount disks/rolfOS.dmg); \
		mkdir loop-tmp; \
		mount -t msdos $$(echo $$MOUNTED_FILE) loop-tmp; \
		cp binaries/* loop-tmp/; \
		sleep 0.2; \
		umount loop-tmp; > /dev/null 2>&1 \
		hdiutil detach $$(echo $$MOUNTED_FILE); > /dev/null 2>&1\
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
	mkdir -p iso-tmp
	cp binaries/* iso-tmp/
	cp disks/* iso-tmp/
	mkisofs -quiet -V 'ROLFOS' -input-charset iso8859-1 -o disks/rolfOS.iso -b rolfOS.flp iso-tmp/
	rm -rf iso-tmp
	@echo "$(COLOR_START)>> Done!$(COLOR_END)"
	
run: runfloppy
	
runfloppy: floppy
	@echo "$(COLOR_START)>> Starting QEMU i386 with floppyimage as floppy...$(COLOR_END)"
	qemu-system-i386 -soundhw pcspk -fda disks/rolfOS.flp -d in_asm
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"
	
runhdd: floppy
	@echo "$(COLOR_START)>> Starting QEMU i386 with floppyimage as hdd...$(COLOR_END)"
	qemu-system-i386 -hda disks/rolfOS.flp
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"

runiso: iso
	@echo "$(COLOR_START)>> Starting QEMU i386 with iso as cd...$(COLOR_END)"
	qemu-system-i386 -cdrom disks/rolfOS.iso
	@echo "$(COLOR_START)>> QEMU exited!$(COLOR_END)"
	
docs:
	cd doc
	doc/tools/asm4doxy.pl -ud $(shell find source/features/ -name '*.asm' | tr -s '\\n')

	cd doc && doxygen Doxyfile

	rm *.c
gh-pages:
	git checkout gh-pages
	git merge master
	git push origin gh-pages
	git checkout master