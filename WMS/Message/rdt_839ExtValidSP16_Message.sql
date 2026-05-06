--rdt_839ExtValidSP16
--FCR-9040
EXECUTE rdt.rdtdropmsg 255301 , 255350

EXECUTE rdt.rdtAddMsg 255301, 10, '255301 NoOpenTask',         'us_english', 839, 0, '255301 No open task'
EXECUTE rdt.rdtAddMsg 255302, 10, '255302 OrdCanceled',        'us_english', 839, 0, '255302 Cancelled order is found'
EXECUTE rdt.rdtAddMsg 255303, 10, '255303 DropIDNeed',         'us_english', 839, 0, '255303 DropID cannot be empty'
EXECUTE rdt.rdtAddMsg 255304, 10, '255304 DropIDInUse',        'us_english', 839, 0, '255304 DropID is in use'
EXECUTE rdt.rdtAddMsg 255305, 10, '255305 InvDropID',          'us_english', 839, 0, '255305 Invalid DropID format'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 255301 AND 255350
