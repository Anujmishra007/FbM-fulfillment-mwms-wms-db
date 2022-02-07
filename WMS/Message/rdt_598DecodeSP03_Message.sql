--rdt_598DecodeSP03

execute rdt.rdtDropMsg 169601, 169650

execute rdt.rdtAddMsg 169601, 10, '169601^Invalid UCC  ',    'us_english', 598
execute rdt.rdtAddMsg 169602, 10, '169602^Double Scan  ',     'us_english', 598


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 169601 AND 169650 