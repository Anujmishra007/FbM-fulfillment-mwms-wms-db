-- rdtfnc_InboundSKUPutaway 
execute rdt.rdtDropMsg 100951 , 101000

execute rdt.rdtAddMsg 100951, 10, '00951^VALUE REQUIRED',   'us_english', 743
execute rdt.rdtAddMsg 100952, 10, '00952^INVALID ID',       'us_english', 743
execute rdt.rdtAddMsg 100953, 10, '00953^NO SUGGEST LOC',   'us_english', 743
execute rdt.rdtAddMsg 100954, 10, '00954^LOC REQUIRED',     'us_english', 743
execute rdt.rdtAddMsg 100955, 10, '00955^INVALID TO LOC',   'us_english', 743
execute rdt.rdtAddMsg 100956, 10, '00956^LOC NOT MATCH',    'us_english', 743
execute rdt.rdtAddMsg 100957, 10, '00957^NO SUGGEST SKU',   'us_english', 743
execute rdt.rdtAddMsg 100958, 10, '00958^SKU/UPC REQ',      'us_english', 743
execute rdt.rdtAddMsg 100959, 10, '00959^INVALID SKU',      'us_english', 743
execute rdt.rdtAddMsg 100960, 10, '00960^MultiSKUBarcod',   'us_english', 743
execute rdt.rdtAddMsg 100961, 10, '00961^SKU NOT MATCH',    'us_english', 743
execute rdt.rdtAddMsg 100962, 10, '00962^INVALID QTY',      'us_english', 743
execute rdt.rdtAddMsg 100963, 10, '00963^INVALID QTY',      'us_english', 743
execute rdt.rdtAddMsg 100964, 10, '00964^QTY NEEDED',       'us_english', 743
execute rdt.rdtAddMsg 100965, 10, '00965^QTY NOT MATCH',    'us_english', 743
execute rdt.rdtAddMsg 100966, 10, '00966^QTYPWY NOTENUF',   'us_english', 743
execute rdt.rdtAddMsg 100967, 10, '00967^INVALID QTY',      'us_english', 743
execute rdt.rdtAddMsg 100968, 10, '00968^INVALID QTY',      'us_english', 743
execute rdt.rdtAddMsg 100969, 10, '00969^INVALID QTY',      'us_english', 743
execute rdt.rdtAddMsg 100970, 10, '00970^NO MORE LOC',      'us_english', 743

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 100951 AND 101000