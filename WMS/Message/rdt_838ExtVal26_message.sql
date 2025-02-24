-- rdt_838ExtVal26
-- UWP-30204
EXECUTE rdt.rdtDropMsg 233201  , 233250

EXECUTE rdt.rdtAddMsg 233201, 10, '233201UCCNotExist',      'us_english', 838, 0, '233201 UCC does not exist'
EXECUTE rdt.rdtAddMsg 233202, 10, '233202InvalidUCCStatus', 'us_english', 838, 0, '233202 Invalid UCC Status'
EXECUTE rdt.rdtAddMsg 233203, 10, '233203DiffPickSlipNo',   'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 233201 AND 233250
