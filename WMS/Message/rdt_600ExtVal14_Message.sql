--rdt_600ExtVal14
execute rdt.rdtDropMsg 200251 , 200300	

execute rdt.rdtAddMsg 200251, 10, '200251 OverMaxPallet',   'us_english', 600

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 200251 AND 200300