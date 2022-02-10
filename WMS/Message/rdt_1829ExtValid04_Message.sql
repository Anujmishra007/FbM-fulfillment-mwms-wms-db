--rdt_1829ExtValid04
exec rdt.rdtDropMsg 135051 , 135100

execute rdt.rdtAddMsg 135051, 10, '35051^Need ASN',      'us_english', 1829
execute rdt.rdtAddMsg 135052, 10, '35052^Invalid ASN',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 135051 AND 135100