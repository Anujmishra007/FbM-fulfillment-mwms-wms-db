--rdt_1841ExtValid01
exec rdt.rdtDropMsg 165951 , 166000

execute rdt.rdtAddMsg 165951, 10, '65951^Lane In Used',      'us_english', 1841


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 165951 AND 166000
