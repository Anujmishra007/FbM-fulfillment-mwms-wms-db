-- rdt_1764ExtUpd21
-- UWP-30476
EXECUTE rdt.rdtdropmsg 233651, 233700

EXECUTE rdt.rdtAddMsg 233651, 10, '233651UpdPKTaskFail',          'us_english', 1764

--FCR-7417
EXECUTE rdt.rdtAddMsg 233652, 10, '233652GenTransmitLogFail',     'us_english', 1764, 0, '233652 Generate TransmitLog Failed'

--FCR-7730
EXECUTE rdt.rdtAddMsg 233653, 10, '233653 UpdPkdFail',            'us_english', 1764, 0, '233653 Update PickDetail Failed'
EXECUTE rdt.rdtAddMsg 233654, 10, '233654 PrintZPLFail',          'us_english', 1764, 0, '233654 Print ZPL Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 233651 AND 233700
