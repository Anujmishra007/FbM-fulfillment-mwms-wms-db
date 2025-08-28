-- rdt_1721ExtValid02
-- FCR-7160
EXECUTE rdt.rdtdropmsg 245451, 245500

EXECUTE rdt.rdtAddMsg 245451, 10, '245451 ToLoc QI', 'us_english', 1721, 0, '245451 ToLoc is QI'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 231251 AND 245500