--rdt_1650ExtUpd02
rdt.rdtDropMsg 201951 , 202000

execute rdt.rdtAddMsg 201951, 10, '201951 PALLET ID REQ',   'us_english', 1650
execute rdt.rdtAddMsg 201952, 10, '201952InsScn2TrkFail',   'us_english', 1650
execute rdt.rdtAddMsg 201953, 10, '201953CloseScn2TrkEr',   'us_english', 1650

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 201951 AND 202000