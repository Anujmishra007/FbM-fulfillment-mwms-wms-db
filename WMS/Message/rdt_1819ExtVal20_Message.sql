-- FCR-6088
-- rdt_1819ExtVal20
EXEC rdt.rdtDropMsg 242751, 242800

EXECUTE rdt.rdtAddMsg 242751, 10, '242751 InvLocType',      'us_english', 1819, 0, '242751 Location type is not CASE'
EXECUTE rdt.rdtAddMsg 242752, 10, '242752 InvLocType',      'us_english', 1819, 0, '242752 Location Putaway Zone is not in LVSCTZONE'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 242751 AND 242800
