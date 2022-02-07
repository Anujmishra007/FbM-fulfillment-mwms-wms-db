-- rdt_1580ExtUpd09
exec rdt.rdtDropMsg 126101 , 126150

execute rdt.rdtAddMsg 126101, 10, '126101^No Printer',   'us_english', 1580

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 126101 AND 126150

