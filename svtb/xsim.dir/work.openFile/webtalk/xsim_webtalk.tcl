webtalk_init -webtalk_dir /home/quinn0/JSONPacketParser/svtb/xsim.dir/work.openFile/webtalk/
webtalk_register_client -client project
webtalk_add_data -client project -key date_generated -value "Wed Jul 25 17:59:26 2018" -context "software_version_and_target_device"
webtalk_add_data -client project -key product_version -value "XSIM v2018.1 (64-bit)" -context "software_version_and_target_device"
webtalk_add_data -client project -key build_version -value "2188600" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_platform -value "LIN64" -context "software_version_and_target_device"
webtalk_add_data -client project -key registration_id -value "174112640_179741397_210594766_948" -context "software_version_and_target_device"
webtalk_add_data -client project -key tool_flow -value "xsim" -context "software_version_and_target_device"
webtalk_add_data -client project -key beta -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key route_design -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_family -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_device -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_package -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_speed -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key random_id -value "07ea8a1e2318590fa2643f4be9176ee4" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_id -value "02658c15-2a67-458e-a351-8a93e2f3c512" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_iteration -value "25" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_name -value "Ubuntu" -context "user_environment"
webtalk_add_data -client project -key os_release -value "Ubuntu 16.04.4 LTS" -context "user_environment"
webtalk_add_data -client project -key cpu_name -value "Intel(R) Xeon(R) CPU E5-2650 v4 @ 2.20GHz" -context "user_environment"
webtalk_add_data -client project -key cpu_speed -value "2511.609 MHz" -context "user_environment"
webtalk_add_data -client project -key total_processors -value "1" -context "user_environment"
webtalk_add_data -client project -key system_ram -value "67.000 GB" -context "user_environment"
webtalk_register_client -client xsim
webtalk_add_data -client xsim -key runall -value "true" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key runall -value "true" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key runall -value "true" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key Command -value "xsim" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key trace_waveform -value "true" -context "xsim\\usage"
webtalk_add_data -client xsim -key runtime -value "0 ps" -context "xsim\\usage"
webtalk_add_data -client xsim -key iteration -value "0" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Time -value "12.09_sec" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Memory -value "124072_KB" -context "xsim\\usage"
webtalk_transmit -clientid 1993158939 -regid "174112640_179741397_210594766_948" -xml /home/quinn0/JSONPacketParser/svtb/xsim.dir/work.openFile/webtalk/usage_statistics_ext_xsim.xml -html /home/quinn0/JSONPacketParser/svtb/xsim.dir/work.openFile/webtalk/usage_statistics_ext_xsim.html -wdm /home/quinn0/JSONPacketParser/svtb/xsim.dir/work.openFile/webtalk/usage_statistics_ext_xsim.wdm -intro "<H3>XSIM Usage Report</H3><BR>"
webtalk_terminate
