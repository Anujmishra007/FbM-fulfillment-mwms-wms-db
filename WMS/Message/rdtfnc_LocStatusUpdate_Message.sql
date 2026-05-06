-- rdtfnc_LocStatusUpdate
-- Message Range: 263501 - 263550
EXEC rdt.rdtDropMsg 263501, 263550

-- Error Messages
EXECUTE rdt.rdtAddMsg 263501, 10, '263501 InvalidLoc',           'us_english', 1879, 0, '263501 Invalid location'
EXECUTE rdt.rdtAddMsg 263502, 10, '263502 InvalidOption',        'us_english', 1879, 0, '263502 Invalid option'
EXECUTE rdt.rdtAddMsg 263503, 10, '263503 HoldPallet',           'us_english', 1879, 0, '263503 HOLD pallets in the location'
EXECUTE rdt.rdtAddMsg 263504, 10, '263504 MixedShipTo',          'us_english', 1879, 0, '263504 Mixed ShipTo'
EXECUTE rdt.rdtAddMsg 263505, 10, '263505 UpdateFail',           'us_english', 1879, 0, '263505 Failed to update location status'
EXECUTE rdt.rdtAddMsg 263506, 10, '263506 NoLocStatus',          'us_english', 1879, 0, '263506 No location status defined'
EXECUTE rdt.rdtAddMsg 263507, 10, '263507 SOCreated',            'us_english', 1879, 0, '263507 SO creation triggered'
EXECUTE rdt.rdtAddMsg 263508, 10, '263508 LocUpdated',           'us_english', 1879, 0, '263508 Location status updated'
EXECUTE rdt.rdtAddMsg 263509, 10, '263509 NoPalletOnLoc',        'us_english', 1879, 0, '263509 No pallets on location'
EXECUTE rdt.rdtAddMsg 263510, 10, '263510 InvalidZone',          'us_english', 1879, 0, '263510 Invalid PutawayZone for ShipTo'
EXECUTE rdt.rdtAddMsg 263511, 10, '263511 QCMDFail',             'us_english', 1879, 0, '263511 Failed to queue SO creation'
EXECUTE rdt.rdtAddMsg 263512, 10, '263512 LocNeeded',            'us_english', 1879, 0, '263512 Location Needed'
EXECUTE rdt.rdtAddMsg 263513, 10, '263513 OptionNeeded',         'us_english', 1879, 0, '263513 Option Needed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263501 AND 263550
