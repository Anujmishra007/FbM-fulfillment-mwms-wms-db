--rdt_1831ExtValid01
exec rdt.rdtDropMsg 124451 , 124500

execute rdt.rdtAddMsg 124451, 10, '24451^LoadKey Needed',   'us_english', 1831
execute rdt.rdtAddMsg 124452, 10, '24452^Invalid Load',     'us_english', 1831
execute rdt.rdtAddMsg 124453, 10, '24453^Diff Facility',    'us_english', 1831
execute rdt.rdtAddMsg 124454, 10, '24454^Diff Storer',      'us_english', 1831
execute rdt.rdtAddMsg 124455, 10, '24455^Load Closed',      'us_english', 1831
execute rdt.rdtAddMsg 124456, 10, '24456^Load Scanned',     'us_english', 1831
execute rdt.rdtAddMsg 124457, 10, '24457^SKU NotIN LOAD',   'us_english', 1831
execute rdt.rdtAddMsg 124458, 10, '24458^SKULockByUser',    'us_english', 1831

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 124451 AND 124500