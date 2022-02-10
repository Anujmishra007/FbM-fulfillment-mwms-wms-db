--rdt_LottableProcess_UNIGenL4L13ByL2
execute rdt.rdtDropMsg 146601 , 146650

execute rdt.rdtAddMsg 146601, 10, '46601^Inv ShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 146602, 10, '46602^Inv Batch No',    'us_english', 600
execute rdt.rdtAddMsg 146603, 10, '46603^Inv Year #',      'us_english', 600
execute rdt.rdtAddMsg 146604, 10, '46604^Inv Week #',      'us_english', 600
execute rdt.rdtAddMsg 146605, 10, '46605^Inv Day #',       'us_english', 600
execute rdt.rdtAddMsg 146606, 10, '46606^Inv Prod Date',   'us_english', 600
execute rdt.rdtAddMsg 146607, 10, '46607^SKU below MRSL',  'us_english', 600
execute rdt.rdtAddMsg 146608, 10, '46608^Inv Prod Date',   'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 146601 AND 146650
