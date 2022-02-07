--rdt_LottableProcess_UNIGenL2L4ByL13	
execute rdt.rdtDropMsg 146651 , 146700

execute rdt.rdtAddMsg 146651, 10, '46651^Inv ShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 146652, 10, '46652^Inv Prod Date',   'us_english', 600
execute rdt.rdtAddMsg 146653, 10, '46653^SKU below MRSL',  'us_english', 600
execute rdt.rdtAddMsg 146654, 10, '46654^Inv Prod Date',   'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 146651 AND 146700
