--rdt_512ExtValid06
--UWP-45367
EXECUTE rdt.rdtdropmsg 253501 , 253550

EXECUTE rdt.rdtAddMsg 253501, 10, '253501 NeedToID',           'us_english', 512, 0, '253501 Need To ID'
EXECUTE rdt.rdtAddMsg 253502, 10, '253502 IDInUse',            'us_english', 512, 0, '253502 ID IN USE'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253501 AND 253550