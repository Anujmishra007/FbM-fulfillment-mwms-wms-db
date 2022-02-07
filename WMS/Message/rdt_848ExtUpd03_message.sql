
SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '179651' AND '179700'

--rdt_848ExtUpd03
EXEC rdt.rdtDropMsg 179651, 179700

execute rdt.rdtAddMsg 179651, 10, '179651 NO PICKKSLIP ',   'us_english', 848
execute rdt.rdtAddMsg 179652, 10, '179652DEL PACKD FAIL',   'us_english', 848