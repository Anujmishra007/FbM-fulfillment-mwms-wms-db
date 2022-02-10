--rdt_PTLStation_CreateTask_ToteIDSKU05
rdt.rdtDropMsg 146751 , 146800

execute rdt.rdtAddMsg 146751, 10, '46751^AssignCartonID',   'us_english', 805
execute rdt.rdtAddMsg 146752, 10, '46752^No task',          'us_english', 805
execute rdt.rdtAddMsg 146753, 10, '46753^INSPTLTranFail',   'us_english', 805

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146751 AND 146800