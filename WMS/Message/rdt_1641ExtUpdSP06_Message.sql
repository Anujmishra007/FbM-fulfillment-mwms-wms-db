--rdt_1641ExtUpdSP06
rdt.rdtDropMsg 147951 , 148000	

execute rdt.rdtAddMsg 147951, 10, '47951^InsPLTFail',       'us_english', 1641
execute rdt.rdtAddMsg 147952, 10, '47952^CartonExist',      'us_english', 1641
execute rdt.rdtAddMsg 147953, 10, '47953^InsPLTDetFail',    'us_english', 1641
execute rdt.rdtAddMsg 147954, 10, '47954^PLTKeyNotFound',   'us_english', 1641
execute rdt.rdtAddMsg 147955, 10, '47955^UpdPLTDetFail',    'us_english', 1641
execute rdt.rdtAddMsg 147956, 10, '47956^UpdPLTFail',       'us_english', 1641


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147951 AND 148000	