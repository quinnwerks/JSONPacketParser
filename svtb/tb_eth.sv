`timescale 1 ns/ 1ps

//import ethernet::*;

typedef struct {
    int data[63:0][22:0];
    int keep[63:0][22:0];
    int last[63:0][22:0];
    int num_flits[63:0];
} json_data;

module conv_json();
    
//    import "DPI-C" function void parseJSON(input string jsonFilePath, inout packet extPacketList[], inout int ver, inout int logToFile);
    import "DPI-C" function void svArrayPasser
        (
        input string jsonFilePath,
        inout int svData[][],
        inout int svKeep[][],
        inout int svLast[][],
        inout int svNumFlits[]
        );

    json_data stream_out;
    string json_file_path;

    initial begin

        json_file_path = "./jsonTests/jsonPacketTest_extensive.json";
        #50
        svArrayPasser
            (
            json_file_path, 
            stream_out.data, 
            stream_out.keep, 
            stream_out.last, 
            stream_out.num_flits
            );

    end

endmodule

module eth_stimulate
    (
    output reg [63:0] stream_out_DATA,
    output reg [7:0] stream_out_KEEP, 
    output reg stream_out_LAST,
    output reg stream_out_VALID,
    input stream_out_READY,
    input [63:0] stream_in_DATA,
    input [7:0] stream_in_KEEP, 
    input stream_in_LAST,
    input stream_in_VALID,
    output reg stream_in_READY
    );


    parameter [47:0] MAC_ADDR_FPGA = 48'hfa163e55ca02; 
    parameter [47:0] MAC_ADDR_STIM = 48'h0cc47a88c047; 

    reg [63:0] stupid_data;
    reg [7:0] stupid_keep;
    reg stupid_last;
    reg stupid_valid;
    
    initial begin

//        static string jsonFilePath = "./jsonTests/jsonPacketTest_extensive.json";
//        packet extPacketList[0:63];
//        static int ver = 1'd0;
//        static int logToFile = 1'd0;
//        parseJSON(jsonFilePath, extPacketList, ver, logToFile);
    
        stream_in_READY = 1'b1;           
        #50
        ethernet_header
            (
            .mac_addr_dst(MAC_ADDR_FPGA),
            .mac_addr_src(MAC_ADDR_STIM), 
            .dst(8'h00)
            );
        
        
        // Hardcoded gen_transactions
        /*
        gen_transaction
                        (
                        .data(64'h0100000100030000), 
                        .keep(8'hff), 
                        .last(1'b0)
                        );
        gen_transaction
                        (
                        .data(64'h5073930200000000), 
                        .keep(8'h0f), 
                        .last(1'b1)
                        );
        */
 
    end

   initial begin

        stupid_data = 64'd69;
        stupid_keep = 8'hff;
        stupid_last = 1'b1;
        stupid_valid = 1'b1;
        // Necessary without assign statements
        #60
        stream_out_DATA = stupid_data;
        stream_out_KEEP = stupid_keep;
        stream_out_LAST = stupid_last;
        stream_out_VALID = stupid_valid;

    end

        // Generate a transaction for each flit
//        for(int i = 0; i < 64; ++i) begin
//            for(int j = 0; j < (extPacketList[i].num_flits); ++j) begin
//                gen_transaction(extPacketList[i].flit_list[j].data, extPacketList[i].flit_list[j].keep, extPacketList[i].flit_list[j].last);
//            end
//        end

    `include "ethernet.sv"
    `include "utility.sv"

endmodule
