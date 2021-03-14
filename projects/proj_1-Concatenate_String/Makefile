concat: concat.o
	gcc -o concat concat.o
concat.o: concat.s
	as -o concat.o concat.s
clean:
	rm -rf concat concat.o
