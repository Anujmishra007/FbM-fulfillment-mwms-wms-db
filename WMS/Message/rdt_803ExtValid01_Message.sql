--rdt_803ExtValid01
rdt.rdtDropMsg 147601 , 147650

execute rdt.rdtAddMsg 147601, 10, 'BIN',                 'us_english', 803
execute rdt.rdtAddMsg 147602, 10, 'ORDERKEY',            'us_english', 803
execute rdt.rdtAddMsg 147603, 10, 'LOADKEY',             'us_english', 803
execute rdt.rdtAddMsg 147604, 10, 'NOT YET CLEARED',     'us_english', 803
execute rdt.rdtAddMsg 147605, 10, '47605^UNASSIGN CART', 'us_english', 803

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147601 AND 147650