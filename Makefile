SHELL=/bin/sh
PL=swipl
DO=@$(PL) -q -t halt -s build.pl -g

build:
	$(DO) build

clean:
	$(DO) clean
