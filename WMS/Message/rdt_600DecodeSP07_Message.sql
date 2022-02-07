-- rdt_600DecodeSP07
execute rdt.rdtDropMsg 161901, 161950

execute rdt.rdtAddMsg 161901, 10, '161901^Invalid QTY  ',   'us_english', 600

SELECT TOP 10 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 161901 and 161950