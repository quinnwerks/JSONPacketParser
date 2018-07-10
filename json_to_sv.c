#include "./JSMN/jsmn.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define BUFFER_SIZE 5000
#define MAX_TOKEN_COUNT 128
#define NUM_MAX_PACKETS 64
#define NUM_FIELDS 3
#define STRING_TOK 3
#define OBJECT_TOK 1
#define PRIMATIVE_TOK 0
#define NUMBER_OF_FLIT_FIELDS 3
#define MAX_NUMBER_FLITS 23


/*
 *  STRUCTS
 */


// Struct for flit data
typedef struct Flit {
    int data;
    int keep;
    int last;
} flit;

// Struct for packet data (max 24 flits)
typedef struct Packet {
    struct Flit flit_list[23];
    int num_flits;
} packet;


/*
 *  HELPER FUNCTIONS
 */


// Read in JSON file
void readFile(char * path, char * outputstr) {
    FILE * input_f;
    char c;
    int index;
    input_f = fopen(path, "rt");
    while((c = fgetc(input_f)) != EOF){
        outputstr[index] = c;
        index++;
    }
    outputstr[index] = '\0';
    fclose(input_f);
    return;
}

//outputs cleaned packet data structure to a text file
void makeFile(char * path, packet * packetList, int listSize){
    FILE * output_f;

    output_f = fopen(path, "w");

    for(int i = 0; i < listSize; i++){
        packet tempPacket = packetList[i];

        for(int j = 0; j < tempPacket.num_flits; j++){         
            flit tempFlit = packetList[i].flit_list[j];
            fprintf(output_f,"%d,\n%d,\n%d,\n", tempFlit.data, tempFlit.keep, tempFlit.last);
            //printf("%d,\n%d,\n%d,\n", tempFlit.data, tempFlit.keep, tempFlit.last);
        }
    }

    fclose(output_f);
}

// Increment index until token type is 3 (string)
// or index is > tokSize
int incUntilString(int index, jsmntok_t * tok, int tokSize) {
    while(tok[index].type != STRING_TOK && index < tokSize) index++;
    return(index);
}

// Find tokLen for string at given index
int getTokLen(jsmntok_t * tok, int  index) {
    return( tok[index].end - tok[index].start);
}

// Build string from token at given index
void buildTokStr(jsmntok_t * tok, char * jsonstr, int index, char * str, int tokLen) {
    for(int i = 0; i < tokLen; i++) str[i] = jsonstr[tok[index].start + i];
    str[tokLen] = '\0';
    return;
}

// Build integer value from token at given index
int buildTokInt(jsmntok_t * tok, char * jsonstr, int index, char * str, int tokLen) {
    buildTokStr(tok, jsonstr, index, str, tokLen);
    return strtol(str, NULL, 0);
}

// Return flit struct datatype from given string
int getFieldType(char * str) {
    if(strcmp(str, "data") == 0) return 0;
    else if(strcmp(str, "keep") == 0) return 1;
    else if(strcmp(str, "last") == 0) return 2;
    else return -1;
}


// Check if new packet (ie next string == "flits")
bool incUntilFlits(int * p_index, jsmntok_t * tok, int tokSize, char * jsonstr) {
    while(*p_index < tokSize) {
        // Find next string
        *p_index = incUntilString(*p_index, tok, tokSize);
        
        // Build string
        int tokLen = getTokLen(tok, *p_index);
        char str[tokLen];
        buildTokStr(tok, jsonstr, *p_index, str, tokLen);

        // If new packet, return false
        if(strcmp("flits", str) == 0) {
            *p_index++;
            return false;
        }
        else return true;
    }

    // Finished file, stop
    return false;
}


// Parse JSON file into its corresponding data structures
void parseJSON(char * jsonFilePath, int * ver) {
    
    char jsonstr[BUFFER_SIZE];
    readFile(jsonFilePath, jsonstr);

    jsmntok_t tok[MAX_TOKEN_COUNT];
    unsigned int tokSize = sizeof(tok)/sizeof(tok[0]); // = MAX_TOKEN_COUNT ?

    jsmn_parser parser;
    jsmn_init(&parser);

    // Error checking
    jsmnerr_t err = jsmn_parse(&parser, jsonstr,  strlen(jsonstr), tok, tokSize);
    switch(err) {
        case -1 : fprintf(stderr, "ERROR: Not enough tokens were provided\n"); exit(EXIT_FAILURE);
        case -2 : fprintf(stderr, "ERROR: Invalid character inside JSON string\n"); exit(EXIT_FAILURE);
        case -3 : fprintf(stderr, "ERROR: The string is not a full JSON packet, more bytes expected\n"); exit(EXIT_FAILURE);
        default : printf("INFO: Valid JSON file provided\n");
    }

    int tokLen = 0;
    int packetIndex = 0;
    bool firstPacket = true;
    packet packetList[NUM_MAX_PACKETS];

    for(int index = 3;; index++) {
        int flitIndex = 0;
        packet tempPacket;

        while(incUntilFlits(&index, tok, tokSize,jsonstr)) {
            flit tempFlit;

            // Constructing flits
            for(int i = 0; i < NUMBER_OF_FLIT_FIELDS; i++) {
                index = incUntilString(index, tok, tokSize);
                tokLen = getTokLen(tok, index);
                char str[tokLen];
                buildTokStr(tok, jsonstr, index, str, tokLen);
                
                int dataLen = getTokLen(tok, index+1);
                char valueStr[dataLen];
                int value = buildTokInt(tok, jsonstr, index + 1, valueStr, dataLen);

                if(strcmp(str, "data") == 0) tempFlit.data = value;
                else if(strcmp(str, "keep") == 0) tempFlit.keep = value;
                else if(strcmp(str, "last") == 0) tempFlit.last = value;
                index++;
            }
            tempPacket.flit_list[flitIndex] = tempFlit;
            flitIndex++;
            tempPacket.num_flits = flitIndex;
        }

        // Make cleaner fix
        if(!firstPacket) {
            packetList[packetIndex] = tempPacket;
            packetIndex++;
        }
        else firstPacket = false;
        if(index >= tokSize) break;
    }
    packetList[packetIndex-1].num_flits--;

    // Verbose
    if(*ver == 1) {
        for(int i = 0; i < packetIndex; i++) {
            printf("Packet[%d]\n|\n", i);
            for(int j = 0; j < packetList[i].num_flits; j++) {
                printf("|----Flit[%d]\n     |----Data: %d\n     |----Keep: %d\n     |----Last: %d\n",
                    j, packetList[i].flit_list[j].data, packetList[i].flit_list[j].keep, packetList[i].flit_list[j].last);
            }
        }
    }
    
    //write cleaned packet output to a file
    makeFile("./outputFiles/testOutput.txt", packetList, packetIndex);
    return;
}


/*
 *  MAIN
 */


int main(int argc, char * argv[]) {
    if(argc == 2) {
        int ver = 0;
        parseJSON(argv[1], &ver);
    }
    // Verbose
    else if((argc == 3) && ((strcmp(argv[1],"-v") == 0) || (strcmp(argv[1], "--verbose") == 0))) {
        int ver = 1;
        parseJSON(argv[2], &ver);
    }
    else {
        fprintf(stderr, "Usage: /path/json_to_sv [options] /path/file.json\nOptions:\n  -v, --verbose        Show output data structure in the command line\n");
        exit(EXIT_FAILURE);
    }

    return(EXIT_SUCCESS);
}
