all: 
	gcc -o ./json_to_sv ./JSMN/jsmn.c json_to_sv.c
clean: 
	$(RM) ./json_to_sv
