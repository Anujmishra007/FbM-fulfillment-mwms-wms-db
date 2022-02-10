--rdt_CPVMultiSKUExtLOT
execute rdt.rdtDropMsg 130301, 130350

execute rdt.rdtAddMsg 130301, 10, '130301Invalid option',   'us_english', 630
execute rdt.rdtAddMsg 130302, 10, '130302SKU1 blank    ',   'us_english', 630
execute rdt.rdtAddMsg 130303, 10, '130303SKU2 blank    ',   'us_english', 630
execute rdt.rdtAddMsg 130304, 10, '130304SKU3 blank    ',   'us_english', 630
execute rdt.rdtAddMsg 130305, 10, '130305No more SKU   ',   'us_english', 630
execute rdt.rdtAddMsg 130306, 10, '130306No more record',   'us_english', 630
