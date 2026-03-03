-- rdt_1721ExtValid02
-- FCR-7160
EXECUTE rdt.rdtdropmsg 245451, 245500

EXECUTE rdt.rdtAddMsg 245451, 10, '245451 ToLoc QI', 'us_english', 1721, 0, '245451 ToLoc is QI'
EXECUTE rdt.rdtAddMsg 245452, 10, '245452 InvalidLoc', 'us_english', 1722, 0, '245452 Invalid LOC'
EXECUTE rdt.rdtAddMsg 245453, 10, '245453 Diff facility', 'us_english', 1722, 0, '245453 Diff facility'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245451 AND 245500
