--rdt_608RefNoLKUP05
execute rdt.rdtDropMsg 126451 , 126500	

execute rdt.rdtAddMsg 126451, 10, '26451^Invalid RefNo',    'us_english', 608
execute rdt.rdtAddMsg 126452, 10, '26452^Multi ASN',        'us_english', 608
execute rdt.rdtAddMsg 126453, 10, '26453^Invalid RefNo',    'us_english', 608
execute rdt.rdtAddMsg 126454, 10, '26454^Multi Orders',     'us_english', 608
execute rdt.rdtAddMsg 126455, 10, '26455^Invalid RefNo',    'us_english', 608
execute rdt.rdtAddMsg 126456, 10, '26456^Multi Orders',     'us_english', 608
execute rdt.rdtAddMsg 126457, 10, '26457^Order NotFound',   'us_english', 608
execute rdt.rdtAddMsg 126458, 10, '26458^GetKey Fail',      'us_english', 608



SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 126451 AND 126500