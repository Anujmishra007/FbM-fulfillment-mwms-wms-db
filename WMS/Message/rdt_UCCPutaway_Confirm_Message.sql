-- rdt_UCCPutaway_Confirm
execute rdt.rdtDropMsg 251901, 251950

execute rdt.rdtAddMsg 251901, 10 ,'251901DEL MLog FAIL ','us_english', 521, 0, '251901 Delete rdt.rdtMoveSerialNoLog fail'
execute rdt.rdtAddMsg 251902, 10 ,'251902INS MLog FAIL ','us_english', 521, 0, '251902 Insert rdt.rdtMoveSerialNoLog fail'
execute rdt.rdtAddMsg 251903, 10 ,'251903DEL MLog FAIL ','us_english', 521, 0, '251903 Delete rdt.rdtMoveSerialNoLog fail'
execute rdt.rdtAddMsg 251904, 10 ,'251904INS MLog FAIL ','us_english', 521, 0, '251904 Insert rdt.rdtMoveSerialNoLog fail'
execute rdt.rdtAddMsg 251905, 10 ,'251905UPD UCC FAIL  ','us_english', 521, 0, '251905 Update UCC fail'
