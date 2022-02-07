-- rdt_1580ExtVal23
execute rdt.rdtDropMsg 176301, 176350

execute rdt.rdtAddMsg 176301, 10, '176301^Lot03<>HostWh', 'us_english', 1580

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 176301 and 176350
