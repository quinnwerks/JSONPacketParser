#json to bin
#############
#Quinn Smith#
###################################################################
# Creates a binary file for entry into a system verilog testbench #
###################################################################

#Binary File Convention is As Follows
# Each field is 8 bytes 
##########################
#     Order of Data      #
##########################
#  File Start:           #
#  Metadata              #
#  - Size of Document    #
#  - Number of Headers   #
#  - Header Start        #
#  - Header End          #
#  - Data Start          #
#  - Data End            # 
#  - Wait Start          #
#  - Wait End            #
#  Data:                 # 
#  - For each entry      #
#    - Data              #
#    - Keep              #
#    - Last              #
#  Header:               #
#  - For each entry      #
#    - Type              #
#      -0, axi stream    # 
#      -1, ethernet      #
#      -2, mpi           #
#    - Packet Start      #
#    - Packet End        #
#    - Info              #
##########################


#stuff being imported
import os
import sys
import json
import re
import collections
import struct


def main(mode, filepath): 


    

    #get file path and create new files   
    if mode == "0":
        repoPath = os.environ.get('SHOAL_PATH')
        if repoPath is None:
            print("Error: SHOAL_PATH not defined in env")
            exit(-1)
        testFileName = repoPath + filepath
    else:
        testFileName = filepath
    if not os.path.isfile(testFileName):
        print("Error: File " + testFileName + " does not exist")
        exit(-2)

    tempFileName = testFileName.replace('.json', '_out.json')
    tempBinName = testFileName.replace('_out.json', '_out.bin')
    if os.path.isfile(tempFileName):
        print("Warning: overwriting existing file " + tempFileName)
    if os.path.isfile(tempBinName):
        print("Warning: overwriting existing file " + tempBinName)
    fRaw = open(testFileName, "r")
    
    #read in json data
    rawData = ""
    rawData = json.loads(fRaw.read())

  
    
    headerAndData = []
    
    
    #Define some constants
    AXI_TYPE = 0
    ETHERNET_TYPE = 1
    MPI_TYPE = 2

    ERR_TYPE = -2 

    #Number of fields defined in metadata
    DATA_OFFSET = 7
    NUM_BYTES_WORD = 8

    
    #begin extracting numerical data
    headerList = []
    typeList = []
    dataList = []
    numHeaders = 0
    for stuff in rawData['packets']:
        if stuff['type'] == "flit":
            headerType = ERR_TYPE
            newData = []
            newHeader = []
            hasHeader = False
            for outerObj in stuff:

                # process headers
                if(outerObj == 'header'):
                    hasHeader = True
                    numHeaders = numHeaders + 1
                    h_word = stuff['header']
                    if h_word['type'] == 'ethernet':
                        headerType = ETHERNET_TYPE
                        newHeader = [0,0,0]
                    elif h_word['type'] == 'mpi':
                        headerType = MPI_TYPE
                        newHeader = [0,0,0,0,0,0,0,0,0,0]
                    else:
                        headerType = ERR_TYPE
                        newHeader = []

                    #newHeader = []
                    
                    for info in h_word['info']:
                        newHeader.append(h_word['info'][info])
                          
                        if headerType == 1:
                            if info == 'mac_src':
                                newHeader[0] = h_word['info'][info] 
                            elif info == 'mac_dst':
                                newHeader[1] = h_word['info'][info] 
                            elif info == 'dst':
                                newHeader[2] = h_word['info'][info] 
                            else:
                                print("err, ethernet")
                                newHeader[0] = h_word['info'][info] 
                        elif headerType == 2:
                            if info == 'dst_rank':
                                newHeader[0] = h_word['info'][info] 
                            elif info == 'src_rank':
                                newHeader[1] = h_word['info'][info] 
                            elif info == 'packet_type':
                                newHeader[2] = h_word['info'][info] 
                            elif info == 'size':
                                newHeader[3] = h_word['info'][info] 
                            elif info == 'tag': 
                                newHeader[4] = h_word['info'][info] 
                            elif info == 'mac_addr_dst':
                                newHeader[5] = h_word['info'][info] 
                            elif info == 'mac_addr_src':  
                                newHeader[6] = h_word['info'][info] 
                            elif info == 'ip_addr_dst': 
                                newHeader[7] = h_word['info'][info] 
                            elif info == 'ip_addr_src':
                                newHeader[8] = h_word['info'][info] 
                            elif info == 'last': 
                                newHeader[9] = h_word['info'][info] 
                            else:  
                                print("err, mpi") 
                                newHeader[0] = h_word['info'][info] 
                        else:
                            newHeader.append(h_word['info'][info])
                
                if(outerObj == 'interface'):
                    if (hasHeader == False) & (stuff['interface']=='axis_net'):
                        headerType = AXI_TYPE
                        numHeaders = numHeaders + 1

                
                
                       
                
                    

                   
                #process data
                if(outerObj == 'payload'):
                    for innerObj in stuff['payload']:
                    
                        arrayObj = [0,0,0]
                        for values in innerObj:
                            if values == 'data':
                                arrayObj[0] = innerObj[values]
                            elif values == 'keep':
                                arrayObj[1] = innerObj[values]
                            elif values == 'last':
                                arrayObj[2] = innerObj[values]
                        newData = newData + arrayObj
            dataList.append(newData)
            typeList.append(headerType)
            headerList.append(newHeader)


        


    #print(len(typeList)) 
    #print(headerList)
    #print(dataList)                   
        


    #build raw single dimentional list to be used when writing to bin file   
    totalData = 0
    totalHeader = 0

    endList = []
    startList = []
    
    dataListBin = []
    headerBin = []
    

    #find start and end addresses for data
    for i in range(len(dataList)):
        #print(headerType)
       
        dataStart = (totalData + DATA_OFFSET + 1) * NUM_BYTES_WORD
        #print(dataStart)
        for j in range(len(dataList[i])):
            totalData = totalData + 1
            dataListBin.append(dataList[i][j])
        dataEnd = (totalData + DATA_OFFSET + 1 ) * NUM_BYTES_WORD
        #print(dataEnd)
        endList.append(dataEnd)
        startList.append(dataStart)
    
    #use data start, end for header data
    for i in range(len(headerList)):
        
        
        if typeList[i] != ERR_TYPE:
            
            headerBin.append(typeList[i]) 
            headerBin.append(startList[i]) 
            headerBin.append(endList[i]) 

            totalHeader = totalHeader +  3 * NUM_BYTES_WORD


            for j in range(len(headerList[i])):
               headerBin.append(headerList[i][j])
               totalHeader = totalHeader + 1 * NUM_BYTES_WORD
            

    



    
        
    #print(len(headerList))
    #print(len(dataList))
    
    print(dataListBin)
    print(len(dataListBin)/3)


    #concatanate the metadata, data and header sections

    totalSize = (DATA_OFFSET + 1 ) * NUM_BYTES_WORD + totalHeader + endList[-1] - startList[0]

    headerStart = endList[-1]
    headerEnd = headerStart  + totalHeader

    waitStart = headerEnd
    waitEnd = headerEnd

    binList = []
    binList.append(totalSize)
    binList.append(numHeaders)
    binList.append(headerStart)
    binList.append(headerEnd)
    binList.append(startList[0])
    binList.append(endList[-1])
    binList.append(waitStart)
    binList.append(waitEnd)
    
    binList = binList + dataListBin
    binList = binList + headerBin

    print(binList[98:])
   
    

    #print(totalSize)
    #print(headerEnd)
    print(numHeaders)
    
    #generate the binary using binList
    binFile = open(tempBinName, 'wb')
    for i in range(len(binList)):
        binFile.write(struct.pack('>Q', binList[i]))
   
    
    


    

    


            

if __name__ == "__main__":

    if (len(sys.argv) == 1):
        print("Usage: python parse_json.py [mode] [filename]")
        print("  Mode: 0 - use relative path from Shoal repo root")
        print("        1 - use absolute file path")
        print("  Filename: JSON file to parse")
        exit(1)

    main(sys.argv[1], sys.argv[2])
