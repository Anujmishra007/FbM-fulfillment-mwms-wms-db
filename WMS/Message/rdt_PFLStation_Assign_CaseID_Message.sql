
-- rdt_PFLStation_Assign_Caseid
execute rdt.rdtDropMsg 160551  , 160600		

execute rdt.rdtAddMsg 160551, 10, '160551UpdLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160552, 10, '160552UpdPTLTranFail', 'us_english', 801
execute rdt.rdtAddMsg 160553, 10, '160553DelLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160554, 10, '160554NeedCaseid', 'us_english', 801
execute rdt.rdtAddMsg 160555, 10, '160555CaseidAssign', 'us_english', 801
execute rdt.rdtAddMsg 160556, 10, '160556NoTask', 'us_english', 801
execute rdt.rdtAddMsg 160557, 10, '160557INSLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160558, 10, '160558INSPTLTranFail', 'us_english', 801
execute rdt.rdtAddMsg 160559, 10, '160559UPDPTLTranFail', 'us_english', 801
execute rdt.rdtAddMsg 160560, 10, '160560InvalidFormat', 'us_english', 801
