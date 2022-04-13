-- rdt_1581ExtVal03
execute rdt.rdtdropmsg 163701, 163750

execute rdt.rdtAddMsg 163701, 10, '163701LocNotMaintain', 'us_english', 1581
execute rdt.rdtAddMsg 163702, 10, '163702Is RSOToloc   ', 'us_english', 1581
execute rdt.rdtAddMsg 163703, 10, '163703Need Lot03    ', 'us_english', 1581
execute rdt.rdtAddMsg 163704, 10, '163704Need Lot02    ', 'us_english', 1581
execute rdt.rdtAddMsg 163705, 10, '163705Iseg Wrong    ', 'us_english', 1581
execute rdt.rdtAddMsg 163706, 10, '63706NotExceptionSKU', 'us_english', 1581


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 163701 and 163750
