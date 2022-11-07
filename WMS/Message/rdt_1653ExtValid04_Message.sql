--rdt_1653ExtValid04
exec rdt.rdtDropMsg 185701 , 185750

execute rdt.rdtAddMsg 185701, 10, '185701 Plt Diff Wave',    'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 185701 AND 185750
