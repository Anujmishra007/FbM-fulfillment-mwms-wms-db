-- rdt_830ExtVal07
-- 277401 - 277450

EXECUTE rdt.rdtdropmsg 277401, 277450

EXECUTE rdt.rdtAddMsg 277401, 10, '277401 NeedDropID',         'us_english', 830, 0, '277401 Need DropID'
EXECUTE rdt.rdtAddMsg 277402, 10, '277402 DupDropID',          'us_english', 830, 0, '277402 Duplicate DropID'
EXECUTE rdt.rdtAddMsg 277403, 10, '277403 WrongDropID',        'us_english', 830, 0, '277403 Wrong DropID'
EXECUTE rdt.rdtAddMsg 277404, 10, '277404 WrongDropID',        'us_english', 830, 0, '277404 Wrong DropID'
EXECUTE rdt.rdtAddMsg 277405, 10, '277405 WrongDropID',        'us_english', 830, 0, '277405 Wrong DropID'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 277401 AND 277450