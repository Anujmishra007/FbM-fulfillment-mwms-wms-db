--rdt_rdt_599ExtVal02
-- FCR-8280
EXECUTE rdt.rdtdropmsg 248751 , 248800

EXECUTE rdt.rdtAddMsg 248751, 10, '248751^RcptGrpNotAllow',          'us_english', 599, 0, '248751 Receipt Group not allowed'
EXECUTE rdt.rdtAddMsg 248752, 10, '248752^IDNeeded',                 'us_english', 599, 0, '248752 ID is needed'
EXECUTE rdt.rdtAddMsg 248753, 10, '248753^IDNotExists',              'us_english', 599, 0, '248753 ID does not exists any more'
EXECUTE rdt.rdtAddMsg 248754, 10, '248754^IDMoved',                  'us_english', 599, 0, '248754 ID is moved'
EXECUTE rdt.rdtAddMsg 248755, 10, '248755^IDAllocated',              'us_english', 599, 0, '248755 ID is allocated'
EXECUTE rdt.rdtAddMsg 248756, 10, '248756^IDPicked',                 'us_english', 599, 0, '248756 ID is picked'
EXECUTE rdt.rdtAddMsg 248757, 10, '248757^IDAllocated',              'us_english', 599, 0, '248757 ID is allocated for replenishment'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE MESSAGE_ID BETWEEN 248751 AND 248800
