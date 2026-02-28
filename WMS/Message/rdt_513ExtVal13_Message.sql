--FCR-6187: rdt_513ExtVal13 - Validate Lottable03 is same between FromID and ToID
-- rdt_513ExtVal13
EXECUTE rdt.rdtDropMsg 242851, 242900

EXECUTE rdt.rdtAddMsg 242851, 10, '242851 Diff Lot03',               'us_english', 513, 0, '242851 Lottable03 need to be the same'
EXECUTE rdt.rdtAddMsg 242852, 10, '242852 LocTypeNotCase',           'us_english', 513, 0, '242852 Location Type must be CASE'
EXECUTE rdt.rdtAddMsg 242853, 10, '242853 InvPutawayZone',           'us_english', 513, 0, '242853 Location Putaway Zone is not in LVSCTZONE'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 242851 AND 242900