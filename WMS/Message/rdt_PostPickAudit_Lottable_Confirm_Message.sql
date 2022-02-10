-- rdt_PostPickAudit_Lottable_Confirm
execute rdt.rdtDropMsg 122001, 122050

execute rdt.rdtAddMsg 122001, 10, '122001GET PPA Fail  ', 'us_english', 903
execute rdt.rdtAddMsg 122002, 10, '122002INS PPA Fail  ', 'us_english', 903
execute rdt.rdtAddMsg 122003, 10, '122003UPD PPA Fail  ', 'us_english', 903
