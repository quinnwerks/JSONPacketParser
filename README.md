# JSONPacketParser
Uses the jsmn parser to parse a json file into a c data structure. This data structure will be used in a system verilog test bench to test the pr region of galapagos. This is a collaboration with @grahamsider.

The jsmn JSON parser can be found here: https://zserge.com/jsmn.html

Usage: /path/json_to_sv [options] /path/file.json
Options:
  -v, --verbose        Show output data structure in the command line