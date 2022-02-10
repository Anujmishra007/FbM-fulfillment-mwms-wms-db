-- rdtHnMDelNotesReprn
-- EXEC RDT.RDTDROPMSG 88951 , 89000


execute rdt.rdtAddMsg '88951', 10, '88301^VALUE REQ',       'us_english'
execute rdt.rdtAddMsg '88952', 10, '88302^INV ORDERS',      'us_english'
execute rdt.rdtAddMsg '88953', 10, '88303^ORD NOT ALLOC',   'us_english'
execute rdt.rdtAddMsg '88954', 10, '88954^LABELPRNTERREQ',  'us_english'
execute rdt.rdtAddMsg '88955', 10, '88955^REPRINT FAILED',  'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 88951 AND 89000
