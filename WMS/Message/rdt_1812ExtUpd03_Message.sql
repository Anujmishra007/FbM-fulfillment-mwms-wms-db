-- rdt_1812ExtUpd03
execute rdt.rdtDropMsg 175751, 175800

execute rdt.rdtAddMsg 175751, 10, '175751^GenTLog2 Fail', 'us_english', 1812

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 175751 and 175800
