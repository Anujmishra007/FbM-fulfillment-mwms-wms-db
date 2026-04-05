-- rdt_1812GetTaskAU
EXEC rdt.rdtDropMsg 263101, 263150

EXECUTE rdt.rdtAddMsg 263101, 10, '263101 NoTaskClosePL',         'us_english', 1812, 0, '263101 No Task. Close PL'
EXECUTE rdt.rdtAddMsg 263102, 10, '263102 NoMoreTask',            'us_english', 1812, 0, '263102 No more task'
EXECUTE rdt.rdtAddMsg 263103, 10, '263103 UpdTaskDtlFail',        'us_english', 1812, 0, '263103 Upd TaskDtl Fail'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263101 AND 263150
