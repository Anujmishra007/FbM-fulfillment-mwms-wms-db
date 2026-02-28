-- rdt_1637ExtValid17
-- FCR-8619
EXECUTE rdt.rdtdropmsg 249501, 249550

EXECUTE rdt.rdtAddMsg 249501, 10, '249501 DuplicatePlt',    'us_english', 1637, 0, '249501 Duplicate PalletID'
EXECUTE rdt.rdtAddMsg 249502, 10, '249502 InDiffCnt',       'us_english', 1637, 0, '249502 Already Scanned in Different Container'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 249501 AND 249550
