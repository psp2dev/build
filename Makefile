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

MULTILIB_FLAGS = --host=arm-none-eabi --prefix=$(PREFIX)
MULTILIB_DIR = $(PREFIX)/arm-none-eabi/lib/psp2

all: all-target-libgcc all-target-multilib all-target-fpu-multilib all-target-thumb-multilib

all-target-libgcc: out/gcc/Makefile
	$(MAKE) -C out/gcc $@

out/gcc/Makefile: gcc/configure out/gcc
	cd out/gcc; ../../gcc/configure --disable-libstdcxx-verbose --enable-languages=c,c++,lto --with-newlib --with-cpu=cortex-a9 --with-fpu=neon-fp16 --target=arm-none-eabi --with-headers=$(PREFIX)/psp2/include --prefix=$(PREFIX)

all-target-multilib: out/multilib/Makefile
	$(MAKE) -C out/multilib

all-target-fpu-multilib: out/multilib/fpu/Makefile
	$(MAKE) -C out/multilib/fpu

all-target-thumb-multilib: out/multilib/thumb/Makefile
	$(MAKE) -C out/multilib/thumb

out/multilib/Makefile: multilib/configure out/multilib
	cd out/multilib; ../../multilib/configure $(MULTILIB_FLAGS)

out/multilib/fpu/Makefile: multilib/configure out/multilib/fpu
	cd out/multilib/fpu; ../../../multilib/configure --with-fpu $(MULTILIB_FLAGS)

out/multilib/thumb/Makefile: multilib/configure out/multilib/thumb
	cd out/multilib/thumb; ../../../multilib/configure --with-thumb $(MULTILIB_FLAGS)

multilib/configure: multilib/aclocal.m4 multilib/configure.ac
	cd multilib; automake --add-missing --gnu -Wno-portability
	cd multilib; autoconf

multilib/aclocal.m4: multilib/configure.ac
	cd multilib; aclocal

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

install: $(MULTILIB_DIR)/libgcc.a	\
	$(MULTILIB_DIR)/fpu/libgcc.a	\
	$(MULTILIB_DIR)/thumb/libgcc.a	\
	$(MULTILIB_DIR)/crtend.o	\
	$(MULTILIB_DIR)/fpu/crtend.o	\
	$(MULTILIB_DIR)/thumb/crtend.o	\
	install-target-multilib	\
	install-target-fpu-multilib install-target-thumb-multilib

$(MULTILIB_DIR)/libgcc.a: out/gcc/arm-none-eabi/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/fpu/libgcc.a: out/gcc/arm-none-eabi/fpu/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/thumb/libgcc.a: out/gcc/arm-none-eabi/thumb/libgcc/libgcc.a
	install $< $@

$(MULTILIB_DIR)/crtend.o: out/gcc/arm-none-eabi/libgcc/crtend.o
	install $< $@

$(MULTILIB_DIR)/fpu/crtend.o: out/gcc/arm-none-eabi/fpu/libgcc/crtend.o
	install $< $@

$(MULTILIB_DIR)/thumb/crtend.o: out/gcc/arm-none-eabi/thumb/libgcc/crtend.o
	install $< $@

install-target-multilib:
	make -C out/multilib install

install-target-fpu-multilib:
	make -C out/multilib/fpu install

install-target-thumb-multilib:
	make -C out/multilib/thumb install

uninstall:
	rm -Rf $(MULTILIB_DIR)

clean:
	rm -Rf out/*
