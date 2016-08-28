.PHONY: all
all:
	gcc -O2 -Wall mandel.c -omandel
	gcc -O2 -Wall mandel.c -fopenacc -omandel-accel
