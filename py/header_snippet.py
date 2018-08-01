print("in HeaderGenerator")
for packet in rawData['packets']:
    if 'header' in packet:
        print("in a header")
        h_word = packet['header']
        valid = 1
        if 'type' in h_word:
            print("found a type")
            if h_word['type'] == 'ethernet':
                print("do stuff with ethernet header")
            elif h_word['type'] == 'mpi':
                print("do stuff with mpi header")
            else:
                valid = 0
                print("this is not a valid type of header")
        else:
            print("ignoring header: no type")

        if valid:
            if 'info' in h_word:
                print('header is valid start processing info')
                for h_info in h_word['info']:
                    print("do stuff with info")    
    else:
        print("ignoring header, no information provided")
