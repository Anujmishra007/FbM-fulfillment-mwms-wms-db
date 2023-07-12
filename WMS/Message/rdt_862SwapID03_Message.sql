-- rdt_862SwapID03
rdt.rdtDropMsg 202051 , 202050

execute rdt.rdtAddMsg 202051, 10, '202051 Wrong ID     ',   'us_english', 862
execute rdt.rdtAddMsg 202052, 10, '202052 Need ID      ',   'us_english', 862
execute rdt.rdtAddMsg 202053, 10, '202053 Over Pick    ',   'us_english', 862
execute rdt.rdtAddMsg 202054, 10, '202054 Invalid ID   ',   'us_english', 862
execute rdt.rdtAddMsg 202055, 10, '202055 ID Multi Rec ',   'us_english', 862
execute rdt.rdtAddMsg 202056, 10, '202056 LOC Not Match',   'us_english', 862
execute rdt.rdtAddMsg 202057, 10, '202057 SKU Not Match',   'us_english', 862
execute rdt.rdtAddMsg 202058, 10, '202058 ID Picked    ',   'us_english', 862
execute rdt.rdtAddMsg 202059, 10, '202059 TaskOffsetErr',   'us_english', 862
execute rdt.rdtAddMsg 202060, 10, '202060NothingSwapped',   'us_english', 862


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 202051 AND 2020500