-- rdt_1812ExtValAU
EXEC rdt.rdtDropMsg 263051, 263100

EXECUTE rdt.rdtAddMsg 263051, 10, '263051 NeedDropID',            'us_english', 1812, 0, '263051 Need DropID'
EXECUTE rdt.rdtAddMsg 263052, 10, '263052 DropIDInUse',           'us_english', 1812, 0, '263052 DropID in use'
EXECUTE rdt.rdtAddMsg 263053, 10, '263053 InvalidDropID',         'us_english', 1812, 0, '263053 Invalid DropID'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263051 AND 263100
