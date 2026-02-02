-- rdt_514ExtVal02
-- FCR-8110
EXECUTE rdt.rdtDropMsg 247801, 247850

EXECUTE rdt.rdtAddMsg 247801, 10, '247801 InsPltDtlFail',            'us_english', 1638, 0, '247801 Insert Pallet Detail Failed'
EXECUTE rdt.rdtAddMsg 247802, 10, '247802 InsEvtLogFail',            'us_english', 1638, 0, '247802 Insert Event Log Failed'
EXECUTE rdt.rdtAddMsg 247803, 10, '247803 NoPackDetailFound',        'us_english', 1638, 0, '247803 No PackDetail Found'
EXECUTE rdt.rdtAddMsg 247804, 10, '247804 OrderAlreadyScanned',      'us_english', 1638, 0, '247804 Order already scanned'
EXECUTE rdt.rdtAddMsg 247805, 10, '247805 UpdPackDetailFail',        'us_english', 1638, 0, '247805 Update PackDetail Failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 247801 AND 247850