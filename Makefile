# Copyright (C) 2015 PSP2SDK Project
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

ifndef PREFIX
ifdef DEVKITARM
PREFIX=$(DEVKITARM)
else
$(error PREFIX is not set)
endif
endif

HEADERS = --with-headers=$(PWD)/libs/include
MULTILIB_FLAGS = --host=arm-none-eabi $(HEADERS) --prefix=$(PREFIX)
MULTILIB_DIR = $(PREFIX)/arm-none-eabi/lib

all: all-target-tools all-target-libs all-target-libgcc	\
	all-target-multilib all-target-fpu-multilib all-target-thumb-multilib

all-target-tools: out/tools/Makefile
	$(MAKE) -C out/tools

all-target-libs: out/libs/Makefile
	$(MAKE) -C out/libs

all-target-libgcc: out/gcc/Makefile
	$(MAKE) -C out/gcc $@

all-target-multilib: out/multilib/Makefile
	$(MAKE) -C out/multilib

all-target-fpu-multilib: out/multilib/fpu/Makefile
	$(MAKE) -C out/multilib/fpu

all-target-thumb-multilib: out/multilib/thumb/Makefile
	$(MAKE) -C out/multilib/thumb

out/tools/Makefile: tools/configure out/tools
	cd out/tools; ../../tools/configure --prefix=$(PREFIX)/psp2

out/libs/Makefile: libs/configure out/libs
	cd out/libs; ../../libs/configure --host=arm-none-eabi --with-multilib=$(MULTILIB_DIR) --prefix=$(PREFIX)/psp2

out/gcc/Makefile: gcc/configure out/gcc
	cd out/gcc; ../../gcc/configure --disable-libstdcxx-verbose --enable-languages=c,c++,lto --with-newlib --with-cpu=cortex-a9 --with-fpu=neon-fp16 --target=arm-none-eabi $(HEADERS) --prefix=$(PREFIX)

out/multilib/Makefile: multilib/configure out/multilib
	cd out/multilib; ../../multilib/configure $(MULTILIB_FLAGS)

out/multilib/fpu/Makefile: multilib/configure out/multilib/fpu
	cd out/multilib/fpu; ../../../multilib/configure --with-fpu $(MULTILIB_FLAGS)

out/multilib/thumb/Makefile: multilib/configure out/multilib/thumb
	cd out/multilib/thumb; ../../../multilib/configure --with-thumb $(MULTILIB_FLAGS)

%configure: %aclocal.m4 %configure.ac
	cd $(@D); automake --add-missing --gnu -Wno-portability
	cd $(@D); autoconf

%aclocal.m4: %configure.ac
	cd $(@D); aclocal

out/tools: out
	mkdir $@

out/libs: out
	mkdir $@

out/gcc: out
	mkdir $@

out/multilib/fpu: out/multilib
	mkdir $@

out/multilib/thumb: out/multilib
	mkdir $@

out/multilib: out
	mkdir $@

out:
	mkdir $@

install: $(MULTILIB_DIR)/psp2/libgcc.a	\
	$(MULTILIB_DIR)/psp2/fpu/libgcc.a	\
	$(MULTILIB_DIR)/psp2/thumb/libgcc.a	\
	$(MULTILIB_DIR)/psp2/crtend.o	\
	$(MULTILIB_DIR)/psp2/fpu/crtend.o	\
	$(MULTILIB_DIR)/psp2/thumb/crtend.o	\
	install-target-tools install-target-libs install-target-multilib	\
	install-target-fpu-multilib install-target-thumb-multilib

install-target-tools:
	make -C out/tools install

install-target-libs:
	make -C out/libs install

install-target-multilib:
	make -C out/multilib install

install-target-fpu-multilib:
	make -C out/multilib/fpu install

install-target-thumb-multilib:
	make -C out/multilib/thumb install

$(MULTILIB_DIR)/psp2/libgcc.a: out/gcc/arm-none-eabi/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/psp2/fpu/libgcc.a: out/gcc/arm-none-eabi/fpu/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/psp2/thumb/libgcc.a: out/gcc/arm-none-eabi/thumb/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/psp2/crtend.o: out/gcc/arm-none-eabi/libgcc/crtend.o
	install $< $@

$(MULTILIB_DIR)/psp2/fpu/crtend.o: out/gcc/arm-none-eabi/fpu/libgcc/crtend.o
	install $< $@

$(MULTILIB_DIR)/psp2/thumb/crtend.o: out/gcc/arm-none-eabi/thumb/libgcc/crtend.o
	install $< $@

uninstall:
	rm -Rf $(MULTILIB_DIR)/psp2 $(MULTILIB_DIR)/psp2.x $(PREFIX)/psp2

clean:
	rm -Rf out/*
