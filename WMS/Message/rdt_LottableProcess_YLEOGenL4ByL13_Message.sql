
--rdt_LottableProcess_YLEOGenL4ByL13	
execute rdt.rdtDropMsg 176651 , 176700	

execute rdt.rdtAddMsg 176651, 10, '76651^Inv ShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 176652, 10, '76652^Inv Prod Date',   'us_english', 600
execute rdt.rdtAddMsg 176653, 10, '76653^SKU below MRSL',  'us_english', 600
execute rdt.rdtAddMsg 176654, 10, '76654^Inv Prod Date',   'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 176651 AND 176700
