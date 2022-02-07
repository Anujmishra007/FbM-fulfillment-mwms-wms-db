

-- rdt_803CloseCartonSP01
execute rdt.rdtDropMsg 165051 , 165100	

execute rdt.rdtAddMsg 165051, 10, '165051UpdPTLPieceFail', 'us_english', 803
execute rdt.rdtAddMsg 165052, 10, '165052Carton/LocIsNull', 'us_english', 803

