-- rdt_1580ExtVal24
execute rdt.rdtdropmsg 163651, 163700

execute rdt.rdtAddMsg 163651, 10, '163651Invalid SKU   ', 'us_english', 1580
execute rdt.rdtAddMsg 163652, 10, '163652OverReceiveRSO', 'us_english', 1580
execute rdt.rdtAddMsg 163653, 10, '163653Invalid L03   ', 'us_english', 1580
execute rdt.rdtAddMsg 163654, 10, '163654Invalid UDF10 ', 'us_english', 1580

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 163651 and 163700
