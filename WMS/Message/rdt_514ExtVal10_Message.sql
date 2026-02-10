--FCR-6187: rdt_514ExtVal10
-- rdt_514ExtVal10
EXECUTE rdt.rdtDropMsg 242901, 242950

EXECUTE rdt.rdtAddMsg 242901, 10, '242901 Diff Lot03',               'us_english', 514, 0, '242901 Lottable03 need to be the same'
EXECUTE rdt.rdtAddMsg 242902, 10, '242902 Diff Lot03',               'us_english', 514, 0, '242902 Lottable03 need to be the same'
EXECUTE rdt.rdtAddMsg 242903, 10, '242903 LocTypeNotCASE',           'us_english', 514, 0, '242903 Location Type must be CASE'
EXECUTE rdt.rdtAddMsg 242904, 10, '242904 InvPutawayZone',           'us_english', 514, 0, '242904 Location Putaway Zone is not in LVSCTZONE'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 242901 AND 242950