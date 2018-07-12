all: 
	gcc -o ./json_to_sv ./include/JSMN/jsmn.c ./include/svdpi.h ./json_to_sv.c
clean: 
	$(RM) ./json_to_sv
