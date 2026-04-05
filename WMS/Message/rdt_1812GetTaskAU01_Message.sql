-- rdt_1812GetTaskAU01 -- 263201 - 263250
EXEC rdt.rdtDropMsg 263201, 263250

EXECUTE rdt.rdtAddMsg 263201, 10, '263201 NoTaskClosePL',         'us_english', 1812, 0, '263201 No Task. Close PL'
EXECUTE rdt.rdtAddMsg 263202, 10, '263202 NoMoreTask',            'us_english', 1812, 0, '263202 No more task'
EXECUTE rdt.rdtAddMsg 263203, 10, '263203 UpdTaskDtlFail',        'us_english', 1812, 0, '263203 Upd TaskDtl Fail'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263201 AND 263250