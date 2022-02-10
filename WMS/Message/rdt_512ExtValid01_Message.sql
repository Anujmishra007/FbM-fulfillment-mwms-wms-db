--rdt_512ExtValid01
execute rdt.rdtdropmsg 94101 , 94150

execute rdt.rdtAddMsg 94101, 10, '94101^WRONG FACILITY',         'us_english'
execute rdt.rdtAddMsg 94102, 10, '94102^OPEN TRN EXIST',         'us_english'
execute rdt.rdtAddMsg 94103, 10, '94103^WRONG FACILITY',         'us_english'
