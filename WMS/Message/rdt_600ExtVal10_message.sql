
-- rdt_600ExtVal10
execute rdt.rdtDropMsg 184351 , 184400	

execute rdt.rdtAddMsg 184351, 10, '184351IDInUse',   'us_english', 600

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 184351 and 184400