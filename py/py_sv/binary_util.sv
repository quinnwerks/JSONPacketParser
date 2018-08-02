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

    string relPath = "../sample_out.bin";
    int fileID;
    int status;
    reg [] mem [];

    initial begin
        openFile(fileID, fileRelPath);
    end
    
    initial begin
        while(!$feof(fileID)) begin
            #50

//            status = $fread(fileID, mem);
//            $display(currByte);
        end
        closeFile(fileID);
    end

    

endmodule