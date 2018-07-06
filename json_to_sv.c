#include "jsmn.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define JSON_FILE_PATH "./jsonexample.json"
#define BUFFER_SIZE 5000
#define MAX_TOKEN_COUNT 128
#define NUM_MAX_PACKETS 64
#define NUM_FIELDS 3
#define STRING_TOK 3
#define OBJECT_TOK 1
#define PRIMATIVE_TOK 0
#define NUMBER_OF_FLIT_FIELDS 3


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
    FILE * f;
    char c;
    int index;
    f = fopen(path, "rt");
    while((c = fgetc(f)) != EOF){
        outputstr[index] = c;
        index++;
    }
    outputstr[index] = '\0';
    fclose(f);
    return;
}




// Increment index until token type is 3 (string)
// or index is > tokSize
int incUntilString(int index, jsmntok_t * tok, int tokSize) {
    //printf("INC UNTIL STRING INDEX: %d", index);
     //printf("token type after flits: %d\n", tok[index].type);
     //printf("condition 1 b4: %d\n", tok[index].type != 3);
    //printf("condition 2 b4: %d\n", index < tokSize);
    while(tok[index].type != STRING_TOK && index < tokSize) {
        //printf("*index BEFORE = %d\n", index);
        index++;
        //printf("condition 1: %d\n", tok[index].type != 3);
        //printf("condition 2: %d\n", index < tokSize);
        //printf("*index AFTER = %d\n", index);
    }
    //printf("INC UNTIL STRING INDEX: %d", index);
    return(index);
}



// Find tokLen for string at given index
int getTokLen(jsmntok_t * tok, int  index) {
    return( tok[index].end - tok[index].start);
}

// Build string from token at given index
void buildTokStr(jsmntok_t * tok, char * jsonstr, int index, char * str, int tokLen) {
    //printf("tok[index].start = %d, tok[index].end = %d", tok[index].start, tok[index].end);
    //printf("string length: %d\n", tokLen);
    for(int i = 0; i < tokLen; i++) {
        //printf("jsonstr[tok[index].start + i] = %c\n", jsonstr[tok[index].start + i]);
        str[i] = jsonstr[tok[index].start + i];
    }
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


//checks to see if next string is "flits"
bool incUntilFlits(int * p_index, jsmntok_t * tok, int tokSize, char * jsonstr){
    while(*p_index < tokSize){
        //find next string
        *p_index = incUntilString(*p_index, tok, tokSize);

        //build the string
        int tokLen = getTokLen(tok, *p_index);
        char str[tokLen];
        buildTokStr(tok, jsonstr, *p_index, str, tokLen);

        printf("incUntilFlits string: %s\n", str);

        //found a new packet, break out of the loop
        if(strcmp("flits", str) == 0){
            printf("New Packet!!\n\n");
            *p_index++;
            return false;
        }
        //still in the current packet, keep processing flits
        else{
            return true;
        }

    }

    //finished file, stop
    return false;
}


// Parse JSON file into its corresponding data structures
void parseJSON(char * jsonstr){

    jsmntok_t tok[MAX_TOKEN_COUNT];
    unsigned int tokSize = sizeof(tok)/sizeof(tok[0]); // = MAX_TOKEN_COUNT ?

    jsmn_parser parser;
    jsmn_init(&parser);

    // Error checking
    jsmnerr_t err = jsmn_parse(&parser, jsonstr,  strlen(jsonstr), tok, tokSize);
    switch(err) {
        case -1 : printf("ERROR: Not enough tokens were provided\n"); return;
        case -2 : printf("ERROR: Invalid character inside JSON string\n"); return;
        case -3 : printf("ERROR: The string is not a full JSON packet, more bytes expected\n"); return;
        default : printf("INFO: Valid JSON packet provided\n");
    }

    //for(int i = 0; i < tokSize; i++) printf("%d: %d\n", i, tok[i].type);


    int tokLen = 0;
    struct Packet packetList[NUM_MAX_PACKETS];
    int packetIndex = 0;
    for(int index = 3;; index++) {
        struct Packet tempPacket;
        int flitIndex = 0;

        while(incUntilFlits(&index, tok, tokSize,jsonstr)){

            //index++;
            struct Flit tempFlit;

            //making a packet
            //while(incUntilFlits(&index,tok,tokSize)){

            //make a single flit
            for(int i = 0; i < NUMBER_OF_FLIT_FIELDS; i++){

                index = incUntilString(index, tok, tokSize);

                tokLen = getTokLen(tok, index);
                //printf("tokLen: %d\n", tokLen);
                char str[tokLen];
                //printf("index = %d, tok[index].type = %d\n", index, tok[index].type);
                buildTokStr(tok, jsonstr, index, str, tokLen);

                int dataLen = getTokLen(tok, index+1);
                char valueStr [dataLen];
                int value = buildTokInt(tok,jsonstr, index + 1, valueStr, dataLen);

                if(strcmp(str, "data")==0){
                    printf("data value: %d\n", value);
                    tempFlit.data = value;
                }
                if(strcmp(str, "keep")==0){
                    printf("keep value: %d\n", value);
                    tempFlit.keep = value;
                }
                if(strcmp(str, "last")==0){
                    printf("last value: %d\n", value);
                    tempFlit.last = value;
                }
                index++;

            }
            tempPacket.flit_list[flitIndex] = tempFlit;
            flitIndex++;
            tempPacket.num_flits = flitIndex;

        }

        packetList[packetIndex] = tempPacket;
        packetIndex++;
        if(index >= tokSize){
             //packetIndex--;
             break;
         }

        //index++;
    }
    packetList[packetIndex-1].num_flits--;
    for(int n = 0; n < packetIndex; n++){
        for(int f = 0; f < packetList[n].num_flits; f++){
            printf("Flit %d of Packet %d data: %d\n", f, n, packetList[n].flit_list[f].data);
        }
    }

}


/*
 *  MAIN
 */


int main(void) {
    char jsonstr[BUFFER_SIZE];
    readFile(JSON_FILE_PATH, jsonstr);

    //printf("%s", jsonstr);
    parseJSON(jsonstr);

    return 0;
}
