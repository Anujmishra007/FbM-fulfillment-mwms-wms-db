

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '180551' AND '180600'

--rdt_608ExtVal12
EXEC rdt.rdtDropMsg 180551, 180600

execute rdt.rdtAddMsg 180551, 10, '180551 Over Receive ',   'us_english', 608
