GNATSTYLE=-gnaty3M79SabCdefhiklnprstux
GNATCHECKS=-gnataeEfoU -gnatwae
AFLDIR="$(HOME)/Downloads/newafl/afl-2.52b"

all:
	gnatmake -s $(GNATCHECKS) $(GNATSTYLE) -O3 advampiric.adb

asm:
	rm advampiric advampiric.o advampiric.ali
	gnatmake -S -O3 advampiric.adb

fuzz:
	AFL_CC=egcc gnatmake -s --GCC="$(AFLDIR)/afl-gcc" advampiric.adb
