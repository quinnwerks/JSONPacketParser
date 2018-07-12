# JSONPacketParser

Uses the JSMN parser to parse a JSON file into a C data structure. This data structure will be used in a SystemVerilog test bench to test the PR region of Galapagos. This is a collaboration with @grahamsider.

## C Program -- Usage/Options

### Usage:

[path to json_to_sv executable] [options] [path to JSON file]

### Options:

-v, --verbose        Show output data structure in the command line

-l, --log            Log output data structure to outputFiles/log.txt

-h, --help           Show help

## SystemVerilog Interfacing

TODO

## Relevant Projects

The JSMN JSON parser can be found here: https://zserge.com/jsmn.html

The Galapagos project can be found here: https://github.com/tarafdar/galapagos