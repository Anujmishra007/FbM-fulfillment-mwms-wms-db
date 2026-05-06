--rdt_1855ExtScn02
-- FCR-10824
EXECUTE rdt.rdtDropMsg 260501, 260550

EXECUTE rdt.rdtAddMsg 260501, 10, '260501 NoTask',             'us_english', 1855, 0, '260501 No task is found'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 260501 AND 260550