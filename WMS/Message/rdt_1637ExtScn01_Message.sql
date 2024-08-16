-- rdt_1637ExtUpd11
--FCR-673
execute rdt.rdtdropmsg 221251, 221300

execute rdt.rdtAddMsg 221251, 10, '221251 ContainerNoIsNeeded',      'us_english', 1637, 0, '221251 Container No Is Needed'
execute rdt.rdtAddMsg 221252, 10, '221252 InvalidContainerNo',       'us_english', 1637, 0, '221252 Invalid Container No'
execute rdt.rdtAddMsg 221253, 10, '221253 NoMBolKey',                'us_english', 1637, 0, '221253 No MBolKey'
execute rdt.rdtAddMsg 221254, 10, '221254 ContainerClosed',          'us_english', 1637, 0, '221254 Container is Closed'
execute rdt.rdtAddMsg 221255, 10, '221255 GetKeyFail',               'us_english', 1637, 0, '221255 Generate Key Failed'
execute rdt.rdtAddMsg 221256, 10, '221256 InsCntFail',               'us_english', 1637, 0, '221256 Insert Container Failed'
execute rdt.rdtAddMsg 221257, 10, '221257 InsCntFail',               'us_english', 1637, 0, '221257 Exception Happens'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 221251 AND 221300
