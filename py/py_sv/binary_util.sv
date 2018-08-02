`timescale 1 ns/ 1ps

task automatic openFile(ref int fileID, ref string fileRelPath);
    $display("Opening File");
    fileID = $fopen(fileRelPath, "rb");
endtask

task automatic closeFile(ref int fileID);
    $display("Closing File");
    $fclose(fileID);
endtask

module binaryUtil();

    string relPath = "sample_out.bin";
    int fileID;
    int currByte;
    reg [31:0] store;

    initial begin
        openFile(fileID, relPath);
    end
    
    initial begin
        //while(!$feof(fileID)) begin
        //    #50

            currByte = $fread( store, fileID);
            $display(currByte);
        //end
        closeFile(fileID);
    end

    

endmodule