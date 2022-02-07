--rdt_628Decode01
rdt.rdtDropMsg 140001 , 140050

execute rdt.rdtAddMsg 140001, 10, '40001^INVALID LABEL',    'us_english', 628
execute rdt.rdtAddMsg 140002, 10, '40002^INVALID LABEL',    'us_english', 628
execute rdt.rdtAddMsg 140003, 10, '40003^INVALID LABEL',    'us_english', 628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140001 AND 140050