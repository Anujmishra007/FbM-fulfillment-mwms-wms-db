--rdt_1638ExtUpd06
exec rdt.rdtDropMsg 179601 , 179650

execute rdt.rdtAddMsg 179601, 10, '179601 No OrderKey  ',   'us_english', 1638
execute rdt.rdtAddMsg 179602, 10, '179602 UpdPLTD Fail ',   'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 179601 AND 179650


