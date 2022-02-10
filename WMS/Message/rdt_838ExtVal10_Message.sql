--rdt_838ExtVal10
execute rdt.rdtDropMsg 180151, 180200

execute rdt.rdtAddMsg 180151, 10, '180151^SecCodeExists', 'us_english'
execute rdt.rdtAddMsg 180152, 10, '180152^InvalidFormat', 'us_english'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 180151 and 180200


