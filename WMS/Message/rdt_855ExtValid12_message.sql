--rdt_855ExtValid12
--FCR-13139, FCR-13167
exec rdt.rdtDropMsg 273301, 273350

--Normal Order error messages
EXECUTE rdt.rdtAddMsg 273301, 10, '273301QTY:PICK!=PACK',     'us_english', 855, 0, '273301 QTY:PICK!=PACK'
EXECUTE rdt.rdtAddMsg 273302, 10, '273302InvalidSKU',         'us_english', 855, 0, '273302 InvalidSKU'
EXECUTE rdt.rdtAddMsg 273304, 10, '273304NeedQC',             'us_english', 855, 0, '273304 NeedQC'
EXECUTE rdt.rdtAddMsg 273305, 10, '273305AuditFinished',      'us_english', 855, 0, '273305 AuditFinished'
EXECUTE rdt.rdtAddMsg 273306, 10, '273306PickNotFinished',    'us_english', 855, 0, '273306 Pick is not finished'

--SUO specific error messages (FCR-13167)
EXECUTE rdt.rdtAddMsg 273307, 10, '273307QTY:PICK!=PACK',     'us_english', 855, 0, '273307 QTY:PICK!=PACK'
EXECUTE rdt.rdtAddMsg 273308, 10, '273308PickNotFinished',    'us_english', 855, 0, '273308 Pick is not finished'
EXECUTE rdt.rdtAddMsg 273311, 10, '273311NeedQC',             'us_english', 855, 0, '273311 NeedQC'
EXECUTE rdt.rdtAddMsg 273312, 10, '273312AuditFinished',      'us_english', 855, 0, '273312 AuditFinished'
EXECUTE rdt.rdtAddMsg 273313, 10, '273313NeedQC',             'us_english', 855, 0, '273313 NeedQC'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 273301 AND 273350