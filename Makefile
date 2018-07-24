all: 
	gcc -o ./json_to_sv ./include/JSMN/jsmn.c ./include/svdpi.h ./json_to_sv.c ./include/json_to_c.h ./include/JSMN/jsmn.h
clean: 
	$(RM) ./json_to_sv
