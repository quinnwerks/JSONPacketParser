`timescale 1 ns/ 1ps

`include "../../svtb/mpi.sv"

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

    reg clk, ready, valid;
    always #5 clk = ~clk;

    string fRelPath = "sample_out.bin";
    int fID, rStatus, sStatus, currPos;
    longint fSize, currData, payData, payKeep, payLast;
    reg [7:0] fData[8];
    reg [63:0] ADDR[6];

    /**
     *  INSTANTIATIONS
     */

    // ETHERNET
    ethernet_interface stream_eth(
        .clk(clk),
        .stream_out_data(payData),
        .stream_out_keep(payKeep),
        .stream_out_last(payLast),
        .stream_out_valid(valid),
        .stream_out_ready(ready),
        .stream_in_data(),
        .stream_in_keep(),
        .stream_in_last(),
        .stream_in_valid(),
        .stream_in_ready()
        );

//    // MPI
//    mpi_interface stream_mpi(
//        .clk(),
//        .stream_out_data(),
//        .stream_out_keep(),
//        .stream_out_last(),
//        .stream_out_valid(),
//        .stream_out_ready(),
//        .stream_in_data(),
//        .stream_in_keep(),
//        .stream_in_last(),
//        .stream_in_valid(),
//        .stream_in_ready()
//        );
//    
//    // AXI
//    axi_stream stream_axi(
//        .data(),
//        .dest(),
//        .keep(),
//        .user(),
//        .last(),
//        .valid(),
//        .ready()
//        );

    /**
     *  PARSE
     */
    
    task bin_init();
        #10
        rStatus = $fread(fData, fID);
        currPos = $ftell(fID);
        fSize = {>>{fData}};
    endtask

    initial begin
        ready = 1'b0;
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
            payData = {>>{fData}};

            rStatus = $fread(fData, fID);
            payKeep = {>>{fData}};

            rStatus = $fread(fData, fID);
            payLast = {>>{fData}};


            stream_eth.write(
                .data(),
                .keep(),
                .last()
            );

            ready = 1'b1;
            ready = 1'b0;

//            stream_mpi.write(
//                .data(),
//                .keep(),
//                .last()
//            );
//
//            stream_axi.write(
//                .data(),
//                .keep(),
//                .last()
//            );

            currPos = $ftell(fID);
        end

        #10
        close_file(fID);
    end

endmodule