boot(T) :-
	nasm(T, 'boot/boot.bin', 'boot/src/boot.asm', ['-fbin', '-Iinclude/boot/', '-Iboot/src/']).

