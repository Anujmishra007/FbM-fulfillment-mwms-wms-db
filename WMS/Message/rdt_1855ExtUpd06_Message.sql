--rdt_1855ExtUpd06
--FCR-10824
EXECUTE rdt.rdtDropMsg 261251, 261300

EXECUTE rdt.rdtAddMsg 261251, 10, '261251 Ins@tDropIDInfoFail',            'us_english', 1855, 0, '261251 Insert data into @tDropIDInfo failed'
EXECUTE rdt.rdtAddMsg 261252, 10, '261252 Ins@tDropIDInfoFail',            'us_english', 1855, 0, '261252 Insert data into @tDropIDInfo failed'
EXECUTE rdt.rdtAddMsg 261253, 10, '261253 InsDropIDFail',                  'us_english', 1855, 0, '261253 Insert data into DropID failed'
EXECUTE rdt.rdtAddMsg 261254, 10, '261254 InsTaskDetailFail',              'us_english', 1855, 0, '261254 Insert data into @tTaskDetail failed'
EXECUTE rdt.rdtAddMsg 261255, 10, '261255 UpdTaskDetailFail',              'us_english', 1855, 0, '261255 Update TaskDetail failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 261251 AND 261300