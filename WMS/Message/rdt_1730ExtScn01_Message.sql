-- rdt_1730ExtScn01
-- FCR-10345
EXECUTE rdt.rdtdropmsg 258701, 258750

EXECUTE rdt.rdtAddMsg 258701, 10, '258701 ToLoc is needed',                               'us_english', 1730
EXECUTE rdt.rdtAddMsg 258702, 10, '258702 Invalid ToLoc',                                 'us_english', 1730
EXECUTE rdt.rdtAddMsg 258703, 10, '258703 Different Facility',                            'us_english', 1730
EXECUTE rdt.rdtAddMsg 258704, 10, '258704 Update InventoryQCDetail failed',               'us_english', 1730

SELECT * FROM  rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 258701 AND 258750