`timescale 1 ns/ 1ps

//TODO
//task automatic readFromFile(ref reg[32:0] data, ref reg [7:0] keep, ref reg [7:0] int last, ref int status, ref int file);
//    status = $fscanf(file,"%d,%d,%d\n",last,data,keep); 
//endtask

task automatic openFile(ref int file);
    $display("Opening File");
    file = $fopen("../outputFiles/svLog.txt", "r");
endtask

task automatic closeFile(ref int file);
    $display("Closing File");
    $fclose(file);
endtask


module fileIO 
            (
            output reg [63:0] out_data, 
            output reg [7:0] out_keep, 
            output reg out_last
            );

    int file;
    int status;
    int NUM_ENTRIES = 3;

    initial begin
        openFile(file);
    end

    initial begin
        while(!$feof(file)) begin
            #10
            status = $fscanf(file, "%d,%d,%d", out_data, out_keep, out_last);
            
            if(status != NUM_ENTRIES) 
                $display("ERROR: Data in file does not match input format. Please check the file.");
        end
        closeFile(file);
    end

endmodule