-- rdt_1767ExtVal01
-- UWP-40373
EXECUTE rdt.rdtdropmsg 245701, 245750

EXECUTE rdt.rdtAddMsg 245701, 10, '245701 UCCNotExist',       'us_english', 1767, 0, '245701 UCC Does Not Exist'

--UWP-48421
EXECUTE rdt.rdtAddMsg 245702, 10, '245702 UCCNotExist',       'us_english', 1767, 0, '245702 UCC is allocated in different location'
EXECUTE rdt.rdtAddMsg 245703, 10, '245703 UCCNotExist',       'us_english', 1767, 0, '245703 UCC pick in progress in different location'
EXECUTE rdt.rdtAddMsg 245704, 10, '245704 UCCNotExist',       'us_english', 1767, 0, '245704 UCC is on Hold in different location'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245701 AND 245750
