import os
import sys
import json
import re
import collections
import bson
import struct

def main(mode, filepath):    
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
    #fTmp = open(tempFileName, "w+")
    #fBinTmp = open(tempBinName, "w+")

    #fRaw = commentRemover(fRaw_commented.read())
    rawData = ""
    rawData = json.loads(fRaw.read())

  
    
    headerAndData = []
    
    # [1] header
    # [2] header type
    # [3] data
    
    #begin extracting numerical data
    headerList = []
    typeList = []
    dataList = []
    numHeaders = 0
    for stuff in rawData['packets']:
        headerType = -2
        newData = []
        newHeader = []
        for outerObj in stuff:
            if(outerObj == 'header'):
                numHeaders = numHeaders + 1
                h_word = stuff['header']
                if h_word['type'] == 'ethernet':
                    headerType = 105
                else:
                    headerType = -1

                newHeader = []
                
                for info in h_word['info']:
                    #print(info)
                    newHeader.append(h_word['info'][info])
                    #print(newHeader)
            else:
                headerType = -2

            #newHeader     

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


        


                    
        


    #print(headerAndData[0][1])
    totalData = 0
    totalHeader = 0

    endList = []
    startList = []
    

    dataOffset = 7 

    numBytesWord = 8
    numBytesPerBit = 8

    bitsPerField = numBytesWord # this will be where the size goes

    dataListBin = []
    headerBin = []
    #get total amount of data


    for i in range(len(dataList)):
        #print(headerType)
       
        dataStart = (totalData + dataOffset + 1) * bitsPerField
        #print(dataStart)
        for j in range(len(dataList[i])):
            totalData = totalData + 1
            dataListBin.append(dataList[i][j])
        dataEnd = (totalData + dataOffset + 1 ) * bitsPerField
        #print(dataEnd)
        endList.append(dataEnd)
        startList.append(dataStart)
    

    for i in range(len(headerList)):
        
        #print(typeList)
        if typeList[i] != -2:
            
            headerBin.append(typeList[i]) #header type
            headerBin.append(startList[i]) #place holder for data start
            headerBin.append(endList[i]) #place holder for data end

            totalHeader = totalHeader +  3 * bitsPerField


            for j in range(len(headerList[i])):
               headerBin.append(headerList[i][j])
               totalHeader = totalHeader + 1 * bitsPerField
            #print(currBinHeader)
            #print(dataOffset)

    #print(dataListBin)
    #print(headerBin)



    
        

    
        


    #now add meta data

    totalSize = (dataOffset + 1 ) * bitsPerField + totalHeader + endList[-1] - startList[0]

    headerStart = endList[-1]
    headerEnd = headerStart  + totalHeader

    waitStart = headerEnd
    waitEnd = headerEnd

    binList = []
    binList.append(totalSize)
    binList.append(headerStart)
    binList.append(headerEnd)
    binList.append(startList[0])
    binList.append(endList[-1])
    binList.append(waitStart)
    binList.append(waitEnd)
    binList.append(numHeaders)
    binList = binList + dataListBin
    binList = binList + headerBin

    print(totalSize)
    print(headerEnd)
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
