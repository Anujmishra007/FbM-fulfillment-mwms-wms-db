-- rdt_1816ExtUpd02
-- --FCR-7417
EXECUTE rdt.rdtdropmsg 245301, 245350

EXECUTE rdt.rdtAddMsg 245301, 10, '245301UPD PKDtl Fail',         'us_english', 1816, 0, '245301 Update PickDetail Failed'
EXECUTE rdt.rdtAddMsg 245302, 10, '245302GenTransmitLogFail',     'us_english', 1816, 0, '245302 Generate TransmitLog Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245301 AND 245350
