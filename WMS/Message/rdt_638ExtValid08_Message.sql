-- rdt_638ExtValid08
execute rdt.rdtDropMsg 176351, 176400

execute rdt.rdtAddMsg 176351, 10, '176351^Lot03<>HostWh', 'us_english', 1580

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 176351 and 176400
