--rdt_1841DecodeSP01
exec rdt.rdtDropMsg 177651, 177700

execute rdt.rdtAddMsg 177651, 10, '177651^Del Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177652, 10, '177652^Invalid SKU  ',   'us_english', 1841
execute rdt.rdtAddMsg 177653, 10, '177653^Invalid SKU  ',   'us_english', 1841
execute rdt.rdtAddMsg 177654, 10, '177654^Ins Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177655, 10, '177655^Upd Log Fail ',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177651 AND 177700


