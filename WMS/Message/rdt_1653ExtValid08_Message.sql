--rdt_1653ExtValid08
exec rdt.rdtDropMsg 200451 , 200500

execute rdt.rdtAddMsg 200451, 10, '200451Plt Diff State',    'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 200451 AND 200500
