-- rdt_1767ExtVal01
-- UWP-40373
EXECUTE rdt.rdtdropmsg 245701, 245750

EXECUTE rdt.rdtAddMsg 245701, 10, '245701 UCCNotExist',       'us_english', 1767, 0, '245701 UCC Does Not Exist'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245701 AND 245750
