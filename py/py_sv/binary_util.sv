`timescale 1 ns/ 1ps

`define SEEK_SET 0
`define SEEK_CUR 1
`define SEEK_END 2

`define OFFSET 8

`define META_ADDR_START 0
`define META_ADDR_END 'h38

`define HEAD_START_ADDR_INDEX 0
`define HEAD_END_ADDR_INDEX   1
`define DATA_START_ADDR_INDEX 2
`define DATA_END_ADDR_INDEX   3
`define WAIT_START_ADDR_INDEX 4
`define WAIT_END_ADDR_INDEX   5

task automatic open_file(ref int fID, ref string fRelPath);
    $display("Opening file...");
    fID = $fopen(fRelPath, "rb");
endtask

task automatic close_file(ref int fID);
    $display("Closing file...");
    $fclose(fID);
endtask

module bin_parse();

    string fRelPath = "sample_out.bin";
    int fID, rStatus, sStatus, currPos;
    longint fSize, currData, flitData, flitKeep, flitLast;
    reg [7:0] fData[8];
    reg [63:0] ADDR[6];

    task bin_init();
        #10
        rStatus = $fread(fData, fID);
        currPos = $ftell(fID);
        fSize = {>>{fData}};
    endtask

    initial begin
        open_file(fID, fRelPath);
        bin_init();

        // METADATA
        for(int i = 0; currPos < `META_ADDR_END; ++i) begin
            #10
            rStatus = $fread(fData, fID);
            currPos = $ftell(fID);
            currData = {>>{fData}};

            ADDR[i] = currData;
        end
        #10

        // DATA
        sStatus = $fseek(fID, ADDR[`DATA_START_ADDR_INDEX], `SEEK_SET);
        currPos = $ftell(fID);
        while(currPos < ADDR[`DATA_END_ADDR_INDEX]) begin
            #10
            rStatus = $fread(fData, fID);
            flitData = {>>{fData}};

            rStatus = $fread(fData, fID);
            flitKeep = {>>{fData}};

            rStatus = $fread(fData, fID);
            flitLast = {>>{fData}};

            currPos = $ftell(fID);
        end

        #10
        close_file(fID);
    end

endmodule