-- rdt_803WCS01
execute rdt.rdtDropMsg 200501, 200550

execute rdt.rdtAddMsg 200501, 10, '200501GetKey Fail   ',   'us_english', 803
execute rdt.rdtAddMsg 200502, 10, '200502INS TCPOUT Err',   'us_english', 803
execute rdt.rdtAddMsg 200503, 10, '200503UPD TCPOUT Err',   'us_english', 803
execute rdt.rdtAddMsg 200504, 10, '200504WCS Send Fail ',   'us_english', 803
