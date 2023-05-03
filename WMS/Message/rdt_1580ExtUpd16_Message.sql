-- rdt_1580ExtUpd16
execute rdt.rdtDropMsg 200551 , 200600

execute rdt.rdtAddMsg 200551, 10, '200551 Delete SNo ER', 'us_english', 1580
execute rdt.rdtAddMsg 200552, 10, '200552 ReverseSNoERR', 'us_english', 1580


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 200551 AND 200600