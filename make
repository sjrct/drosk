#!/bin/sh

if [[ -z $1 ]]; then
	TARGET=build
else
	TARGET=$1
fi

swipl -q -g $TARGET -t halt -s build.pl

