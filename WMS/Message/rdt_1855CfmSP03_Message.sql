--rdt_1855ExtScn02
--FCR-10824
EXECUTE rdt.rdtDropMsg 260551, 260600

EXECUTE rdt.rdtAddMsg 260551, 10, '260551 UPDPKDtlFail',             'us_english', 1855, 0, '260551 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260552, 10, '260552 UPDPKDtlFail',             'us_english', 1855, 0, '260552 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260553, 10, '260553 UPDPKDtlFail',             'us_english', 1855, 0, '260553 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260554, 10, '260554 UPDTaskFail',              'us_english', 1855, 0, '260554 Update TaskDetail failed'
EXECUTE rdt.rdtAddMsg 260555, 10, '260555 nspg_GetKey',              'us_english', 1855, 0, '260555 Generate PickDetailKey failed'
EXECUTE rdt.rdtAddMsg 260556, 10, '260556 InsPkdFail',               'us_english', 1855, 0, '260556 Insert PickDetail failed'
EXECUTE rdt.rdtAddMsg 260557, 10, '260557 InsRefKeyFail',            'us_english', 1855, 0, '260557 Insert RefKeyLookup failed'
EXECUTE rdt.rdtAddMsg 260558, 10, '260558 UPDPKDtlFail',             'us_english', 1855, 0, '260558 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260559, 10, '260559 UPDPKDtlFail',             'us_english', 1855, 0, '260559 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260560, 10, '260560 UPDPKDtlFail',             'us_english', 1855, 0, '260560 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 260561, 10, '260561 UPDTaskFail',              'us_english', 1855, 0, '260561 Update TaskDetail failed'
EXECUTE rdt.rdtAddMsg 260562, 10, '260562 UPDTaskFail',              'us_english', 1855, 0, '260562 Update TaskDetail failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 260551 AND 260600