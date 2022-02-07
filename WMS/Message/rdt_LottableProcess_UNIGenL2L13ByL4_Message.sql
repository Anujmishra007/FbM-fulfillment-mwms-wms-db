--rdt_LottableProcess_UNIGenL2L13ByL4	
execute rdt.rdtDropMsg 146701 , 146750

execute rdt.rdtAddMsg 146701, 10, '46701^Inv ShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 146702, 10, '46702^Inv Prod Date',   'us_english', 600
execute rdt.rdtAddMsg 146703, 10, '46703^SKU below MRSL',  'us_english', 600
execute rdt.rdtAddMsg 146704, 10, '46704^Inv Prod Date',   'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 146701 AND 146750
