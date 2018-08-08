`timescale 1 ns/ 1ps

task automatic openFile(ref int fileID, ref string fileRelPath);
    $display("Opening File");
    fileID = $fopen(fileRelPath, "rb");
endtask

task automatic closeFile(ref int fileID);
    $display("Closing File");
    $fclose(fileID);
endtask

function automatic getNextByte(ref int fileID, int numBytes)
    reg [numBytes*8-1:0] store;
    int nextByte;
    nextByte = $fread(store, fileID);
    return nextByte;
endfunction

module binaryUtil();

    string relPath = "sample_out.bin";
    int fileID;
    int readStatus;
    // TODO: Make dynamic
    reg [7:0] mem['hac2];

    initial begin
        openFile(fileID, relPath);
    end
    
    initial begin
        #50
        readStatus = $fread(mem, fileID);
        #50
        if(readStatus == 'hac2) begin
            $display("EOF REACHED");
        end
        closeFile(fileID);
    end

    

endmodule