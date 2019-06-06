# Name
name		:= TestSNES
debug		:= 1


# Use packages
libsfx_packages := LZ4

# Derived data files
derived_files	:= src/assets/intech.png.palette src/assets/intech.png.tiles src/assets/intech.png.map
derived_files	+= src/assets/intech.png.tiles.lz4 src/assets/intech.png.map.lz4

# Include libSFX.make
libsfx_dir	:= ../../libSFX
include $(libsfx_dir)/libSFX.make

cfiles = src/*.c

all: cleanC clean default

buildc: SHELL:=/bin/bash
buildc: cleanC $(cfiles)
	mkdir buildc/
	mkdir buildc/src
	cp $(cfiles) buildc/src/
	@cd buildc && echo $$PWD && for x in $$(ls src/*.c); do cc65 -T --cpu 65816 "$$x"; done

Play: buildc TestSNES.sfc
	snes9x-gtk TestSNES.sfc

cleanC:
	rm -r buildc/