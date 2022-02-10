--rdt_1628ExtUpd01
exec rdt.rdtDropMsg 117501 , 117550

execute rdt.rdtAddMsg 117501, 10, '17501^ShortPICK Fail', 'us_english', 1628
execute rdt.rdtAddMsg 117502, 10, '17502^ShortPICK Fail', 'us_english', 1628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 117501 AND 117550
