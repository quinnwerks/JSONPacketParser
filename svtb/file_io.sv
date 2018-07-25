//TODO
//task automatic readFromFile(ref reg[32:0] data, ref reg [7:0] keep, ref reg [7:0] int last, ref int status, ref int file);
//    status = $fscanf(file,"%d,%d,%d\n",last,data,keep); 
//endtask

task automatic openFile(ref int file);
    $display("Opening File");
    file = $fopen("../outputFiles/log.txt", "r");
endtask

task automatic closeFile(ref int file);
    $display("Closing File");
    $fclose(file);
endtask


module fileIO(
            output reg [63:0] out_data, 
            output reg [7:0] out_keep, 
            output reg out_last
            );
    int file;
    int status;
    int data, keep, last;
    initial begin
        openFile(file);

        while(!$feof(file)) begin
            $fscanf(file, "%d,%d,%d",data, keep, last);
            $display(data);
            $display(keep);
            $display(last);
            //#10;
        end       
        closeFile(file);
    end

endmodule