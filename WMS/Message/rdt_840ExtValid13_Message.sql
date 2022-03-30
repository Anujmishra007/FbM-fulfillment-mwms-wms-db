--rdt_840ExtValid13
exec rdt.rdtDropMsg 179101 , 179150

execute rdt.rdtAddMsg 179101, 10, '179101 CODE EXISTS  ',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 179101 AND 179150


