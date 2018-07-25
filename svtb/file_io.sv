
task automatic readFromFile(ref int data, ref int keep, ref int last, ref int status, ref int file);
    status = $fscanf(file,"%d,%d,%d\n",last,data,keep); 
endtask

task automatic openFile(ref int file);
    $display("Opening File");
    file = $fopen("../outputFiles/log.txt", "r");
endtask

task automatic closeFile(ref int file);
    $display("Closing File");
    $fclose(file);
endtask


module openFile();
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
        end       
        closeFile(file);
    end

endmodule