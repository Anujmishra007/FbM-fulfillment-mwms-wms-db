
execute rdt.rdtdropmsg 260250, 257520

execute rdt.rdtAddMsg 260251, 10, '260251: INVALID_PALLET_ID',       'us_english', 511, 0, '260251: INVALID PALLET ID'
execute rdt.rdtAddMsg 260252, 10, '260252: ORDER_NOT_FOUND',         'us_english', 511, 0, '260252: ORDER NOT FOUND'
execute rdt.rdtAddMsg 260253, 10, '260253: LOC_NOT_MATCH',           'us_english', 511, 0, '260253: LOC NOT MATCH'
execute rdt.rdtAddMsg 260254, 10, '260254: LOC NOT MATCH',           'us_english', 511, 0, '260254: LOC NOT MATCH'
EXECUTE rdt.rdtAddMsg 260255, 10, '260255: LOC NOT MATCH',           'us_english', 511, 0, '260255: LOC NOT MATCH'
EXECUTE rdt.rdtAddMsg 260256, 10, '260256: LOC_NOT_IN_LANE',         'us_english', 511, 0, '260256: LOC_NOT_IN_LANE'
EXECUTE rdt.rdtAddMsg 260257, 10, '260257: LOC NOT MATCH',           'us_english', 511, 0, '260257: LOC NOT MATCH'


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 260250 AND 257520