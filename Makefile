# Copyright (C) 2015 PSP2SDK Project
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

ifndef PREFIX
$(error PREFIX is not set)
endif

all: all-target-libgcc

all-target-libgcc: out/gcc/Makefile
	$(MAKE) -C out/gcc $@

out/gcc/Makefile: gcc/configure out/gcc
	cd out/gcc; ../../gcc/configure --disable-libstdcxx-verbose --enable-languages=c,c++,lto --with-newlib --with-cpu=cortex-a9 --with-fpu=neon-fp16 --target=arm-none-eabi --with-headers=$(PREFIX)/psp2/include --prefix=$(PREFIX)

out/gcc: out
	mkdir $@

out:
	mkdir $@

install: $(PREFIX)/arm-none-eabi/lib/psp2/libgcc.a	\
	$(PREFIX)/arm-none-eabi/lib/psp2/fpu/libgcc.a	\
	$(PREFIX)/arm-none-eabi/lib/psp2/thumb/libgcc.a	\
	$(PREFIX)/arm-none-eabi/lib/psp2/crtend.o	\
	$(PREFIX)/arm-none-eabi/lib/psp2/fpu/crtend.o	\
	$(PREFIX)/arm-none-eabi/lib/psp2/thumb/crtend.o

$(PREFIX)/arm-none-eabi/lib/psp2/libgcc.a: out/gcc/arm-none-eabi/libgcc/libgcc.a
	install $< $@

$(PREFIX)/arm-none-eabi/lib/psp2/fpu/libgcc.a: out/gcc/arm-none-eabi/fpu/libgcc/libgcc.a
	install $< $@

$(PREFIX)/arm-none-eabi/lib/psp2/thumb/libgcc.a: out/gcc/arm-none-eabi/thumb/libgcc/libgcc.a
	install $< $@

$(PREFIX)/arm-none-eabi/lib/psp2/crtend.o: out/gcc/arm-none-eabi/libgcc/crtend.o
	install $< $@

$(PREFIX)/arm-none-eabi/lib/psp2/fpu/crtend.o: out/gcc/arm-none-eabi/fpu/libgcc/crtend.o
	install $< $@

$(PREFIX)/arm-none-eabi/lib/psp2/thumb/crtend.o: out/gcc/arm-none-eabi/thumb/libgcc/crtend.o
	install $< $@

uninstall:
	rm -Rf $(PREFIX)/arm-none-eabi/lib/psp2

clean:
	rm -Rf out/*
