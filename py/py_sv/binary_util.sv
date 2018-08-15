`timescale 1 ns/ 1ps

`include "../../svtb/mpi.sv"

`define SEEK_SET 0
`define SEEK_CUR 1
`define SEEK_END 2

`define OFFSET 8

`define META_ADDR_START 0
`define META_ADDR_END 'h40

`define HEAD_START_ADDR_INDEX 0
`define HEAD_END_ADDR_INDEX   1
`define DATA_START_ADDR_INDEX 2
`define DATA_END_ADDR_INDEX   3
`define WAIT_START_ADDR_INDEX 4
`define WAIT_END_ADDR_INDEX   5

`define RAW_AXI  0
`define ETHERNET 1
`define MPI      2

task automatic open_file(ref int f_id, ref string f_rel_path);
    $display("Opening file...");
    f_id = $fopen(f_rel_path, "rb");
endtask

task automatic close_file(ref int f_id);
    $display("Closing file...");
    $fclose(f_id);
endtask

module bin_parse();

    string f_rel_path = "sample_out.bin";
    int f_id, r_status, s_status;
    longint curr_header_pos, curr_data_pos, curr_data_end_pos;
    longint f_size, num_packets, pay_data, pay_keep, pay_last, curr_header_type;
    reg [7:0] f_data[8];
    reg [63:0] addr[6];
    // ETHERNET/MPI
    longint mac_src, mac_dst, dst, dst_rank, src_rank, packet_type, size, tag, ip_dst, ip_src, last;;

    /**
     *  INSTANTIATIONS
     */

    /**
     *  FREAD TASKS
     */
    
    task bin_init();
        r_status = $fread(f_data, f_id);
        f_size = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        num_packets = {>>{f_data}};
    endtask

    task gen_head();
        r_status = $fread(f_data, f_id);
        curr_header_type = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        curr_data_pos = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        curr_data_end_pos = {>>{f_data}};
    endtask

    task eth_head();
        r_status = $fread(f_data, f_id);
        mac_src = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        mac_dst = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        dst = {>>{f_data}};
    endtask

    task mpi_head();
        r_status = $fread(f_data, f_id);
        dst_rank = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        src_rank = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        packet_type = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        size = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        tag = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        mac_dst = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        mac_src = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        ip_dst = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        ip_src = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        last = {>>{f_data}};
    endtask

    task pay_flit();
        r_status = $fread(f_data, f_id);
        pay_data = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        pay_keep = {>>{f_data}};

        r_status = $fread(f_data, f_id);
        pay_last = {>>{f_data}};
    endtask

    /**
     *  INIT BEGIN
     */

    initial begin
        open_file(f_id, f_rel_path);
        #10
        bin_init();
        curr_data_pos = $ftell(f_id);

        // METADATA
        for(int i = 0; curr_data_pos < `META_ADDR_END; ++i) begin
            #10
            r_status = $fread(f_data, f_id);
            addr[i] = {>>{f_data}};
            curr_data_pos = $ftell(f_id);
        end

        // DATA & HEADERS
        #10
        s_status = $fseek(f_id, addr[`HEAD_START_ADDR_INDEX], `SEEK_SET);
        curr_header_pos = $ftell(f_id);

        while(curr_header_pos < addr[`HEAD_END_ADDR_INDEX]) begin
            #10
            gen_head();
            if(curr_header_type == `ETHERNET) begin
                eth_head();
            end
            else if(curr_header_type == `MPI) begin
                mpi_head();
            end
            #10
            curr_header_pos = $ftell(f_id); // NEXT HEADER
            s_status = $fseek(f_id, curr_data_pos, `SEEK_SET);
            while(curr_data_pos < curr_data_end_pos) begin
                #10
                pay_flit();
                curr_data_pos = $ftell(f_id);
            end
            s_status = $fseek(f_id, curr_header_pos, `SEEK_SET);
        end

        #10
        close_file(f_id);
    end

endmodule