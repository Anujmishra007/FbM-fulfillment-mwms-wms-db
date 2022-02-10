-- rdt_PTLCart_CloseCart
execute rdt.rdtDropMsg 53251, 53300

execute rdt.rdtAddMsg 53251, 10, '53251^DEL DPL Fail  ', 'us_english', 808
execute rdt.rdtAddMsg 53252, 10, '53252^DEL PTL Fail  ', 'us_english', 808
