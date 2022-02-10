-- rdt_807ExtInfo01

execute rdt.rdtDropMsg 134001, 57350

execute rdt.rdtAddMsg 134001, 10, 'LOC:               ',    'us_english', 807

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134001 AND 134050

