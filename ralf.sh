if [ "Darwin" == "Darwin" ]; then 
	echo ""\\033[31m"Compiling C-Programs on OS X doesn't work yet..."\\033[0m"" 
else 
	mkdir -p binaries/ 
	gcc -nostdlib -nostartfiles -nodefaultlibs -mno-red-zone source/programs/hwc.c -o binaries/hwc.o;
	
	
	rm binaries/*.o 
fi

echo "Done!"