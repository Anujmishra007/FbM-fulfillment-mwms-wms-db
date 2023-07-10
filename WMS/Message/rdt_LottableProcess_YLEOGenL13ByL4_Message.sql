--rdt_LottableProcess_YLEOGenL13ByL4	
execute rdt.rdtDropMsg 176701 , 176750

execute rdt.rdtAddMsg 176701, 10, '76701^Inv ShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 176702, 10, '76702^Inv Prod Date',   'us_english', 600
execute rdt.rdtAddMsg 176703, 10, '76703^SKU below MRSL',  'us_english', 600
execute rdt.rdtAddMsg 176704, 10, '76704^Inv Prod Date',   'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 176701 AND 176750
