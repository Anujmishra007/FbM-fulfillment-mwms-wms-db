--rdt_855ExtValid12
--FCR-13139
exec rdt.rdtDropMsg 273301, 273350

EXECUTE rdt.rdtAddMsg 273301, 10, '273301QTY:PICK!=PACK',     'us_english', 855
EXECUTE rdt.rdtAddMsg 273302, 10, '273302InvalidSKU',         'us_english', 855
EXECUTE rdt.rdtAddMsg 273303, 10, '273303InvlidOption',       'us_english', 855
EXECUTE rdt.rdtAddMsg 273304, 10, '273304NeedQC',             'us_english', 855
EXECUTE rdt.rdtAddMsg 273305, 10, '273305AuditFinished',      'us_english', 855
EXECUTE rdt.rdtAddMsg 273306, 10, '273306PickNotFinished',    'us_english', 855, 0, '273306 Pick is not finished'
EXECUTE rdt.rdtAddMsg 273307, 10, '273307QTY:PICK!=PACK',     'us_english', 855
EXECUTE rdt.rdtAddMsg 273308, 10, '273308PickNotFinished',    'us_english', 855, 0, '273308 Pick is not finished'
EXECUTE rdt.rdtAddMsg 273309, 10, '273309OnlyOpt1Allowed',    'us_english', 855, 0, '273309 Only option 1 allowed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 273301 AND 273350