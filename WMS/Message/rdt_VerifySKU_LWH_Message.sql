--rdt_VerifySKU_LWH
execute rdt.rdtDropMsg 55701, 55750

execute rdt.rdtAddMsg 55701, 10, '55701 Need L x W x H',   'us_english'
execute rdt.rdtAddMsg 55702, 10, '55702 Invalid format',   'us_english'
execute rdt.rdtAddMsg 55703, 10, '55703 Invalid format',   'us_english'
execute rdt.rdtAddMsg 55704, 10, '55704 Need length   ',   'us_english'
execute rdt.rdtAddMsg 55705, 10, '55705 Need width    ',   'us_english'
execute rdt.rdtAddMsg 55706, 10, '55706 Need height   ',   'us_english'
execute rdt.rdtAddMsg 55707, 10, '55707 Invalid length',   'us_english'
execute rdt.rdtAddMsg 55708, 10, '55708 Invalid width ',   'us_english'
execute rdt.rdtAddMsg 55709, 10, '55709 Invalid height',   'us_english'
