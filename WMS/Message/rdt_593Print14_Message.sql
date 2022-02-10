--rdt_593Print14
exec rdt.rdtDropMsg 116601 , 116650

execute rdt.rdtAddMsg 116601, 10, '16601^VALUE REQUIRED',   'us_english', 593
execute rdt.rdtAddMsg 116602, 10, '16602^NO MATCH FOUND',   'us_english', 593
execute rdt.rdtAddMsg 116603, 10, '16603^ORD X PACK CFM',   'us_english', 593
execute rdt.rdtAddMsg 116604, 10, '16604^NO INVOICE VAL',   'us_english', 593
execute rdt.rdtAddMsg 116605, 10, '16605^SETUP CODEKLP',    'us_english', 593
execute rdt.rdtAddMsg 116606, 10, '16606^NO PDF INVOICE',   'us_english', 593
execute rdt.rdtAddMsg 116607, 10, '16607^INV PRINTER',      'us_english', 593
execute rdt.rdtAddMsg 116608, 10, '16608^NO PRINTER',       'us_english', 593
execute rdt.rdtAddMsg 116609, 10, '16609^PRINT FAIL',       'us_english', 593
execute rdt.rdtAddMsg 116610, 10, '16610^INS JOB FAIL',     'us_english', 593

select * from rdt.rdtmsg (nolock) where message_id between 116601 and 116650



