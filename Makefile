SHELL=/bin/sh
PL=swipl
DO=@$(PL) -q -t halt -s build.pl -g

build:
	$(DO) build

clean:
	$(DO) clean

help:
	@echo "make interface to drosk's build system"
	@echo
	@echo "make [build]     - Build everything."
	@echo "make <clean>     - Clean everything."
	@echo "make build-<foo> - Build <foo>."
	@echo "make clean-<foo> - Clean <foo>."
	@echo "make help        - Display this helpful information."

build-%:
	$(DO) "build($(@:build-%=%))"

clean-%:
	$(DO) "clean($(@:clean-%=%))"

