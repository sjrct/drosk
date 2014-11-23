boot :-
	writeln('Building boot'),
	prefix('boot/src/', [
		'leftovers.inc',
		'before/error16.inc',
		'before/read.inc',
		'after/a20.inc',
		'after/detect.inc',
		'after/fs.inc',
		'after/gdt.inc',
		'after/graphics.inc'
	], Extra),
	nasm('boot/boot.bin', 'boot/src/boot.asm', '-fbin -Iinclude/boot/ -Iboot/src/', Extra).

