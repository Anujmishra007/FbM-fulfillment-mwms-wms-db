-- rdt_1812ExtUpdAU03 --  263251 - 263300
EXEC rdt.rdtDropMsg 263251, 263300

-- Scenario 1: CS or EA
EXECUTE rdt.rdtAddMsg 263251, 10, '263251 InsPkDtlFail',          'us_english', 1812, 0, '263251 Insert PackDetail Failed (CS or EA)'
EXECUTE rdt.rdtAddMsg 263252, 10, '263252 UpdPkInfoFail',         'us_english', 1812, 0, '263252 Update PackInfo Failed (CS or EA)'
EXECUTE rdt.rdtAddMsg 263253, 10, '263253 InsTrnsLogFail',        'us_english', 1812, 0, '263253 Insert TransmitLog Failed (CS or EA)'

-- Scenario 2: CS Only
EXECUTE rdt.rdtAddMsg 263254, 10, '263254 InsPkDtlFail',          'us_english', 1812, 0, '263254 Insert PackDetail Failed (CS Only)'
EXECUTE rdt.rdtAddMsg 263255, 10, '263255 UpdPkInfoFail',         'us_english', 1812, 0, '263255 Update PackInfo Failed (CS Only)'
EXECUTE rdt.rdtAddMsg 263256, 10, '263256 InsTrnsLogFail',        'us_english', 1812, 0, '263256 Insert TransmitLog Failed (CS Only)'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263251 AND 263300
