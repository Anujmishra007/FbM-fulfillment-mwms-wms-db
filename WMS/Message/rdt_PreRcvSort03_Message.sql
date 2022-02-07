-- rdt_PreRcvSort03
exec rdt.rdtDropMsg 119601 , 119650

execute rdt.rdtAddMsg 119601, 10, '19601^No ASN#',          'us_english', 1829
execute rdt.rdtAddMsg 119602, 10, '19602^INS PRERCV ERR',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 119601 AND 119650