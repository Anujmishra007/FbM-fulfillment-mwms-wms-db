-- rdt_1637ExtUpd11
--FCR-673
execute rdt.rdtdropmsg 221351, 221400

execute rdt.rdtAddMsg 221351, 10, '221351 ContainerNoIsNeeded',      'us_english', 1637, 0, '221351 Container No Is Needed'
execute rdt.rdtAddMsg 221352, 10, '221352 InvalidContainerNo',       'us_english', 1637, 0, '221352 Invalid Container No'
execute rdt.rdtAddMsg 221353, 10, '221353 NoMBolKey',                'us_english', 1637, 0, '221353 No MBolKey'
execute rdt.rdtAddMsg 221354, 10, '221354 ContainerClosed',          'us_english', 1637, 0, '221354 Container is Closed'
execute rdt.rdtAddMsg 221355, 10, '221355 GetKeyFail',               'us_english', 1637, 0, '221355 Generate Key Failed'
execute rdt.rdtAddMsg 221356, 10, '221356 InsCntFail',               'us_english', 1637, 0, '221356 Insert Container Failed'
execute rdt.rdtAddMsg 221357, 10, '221357 ExcepHappens',               'us_english', 1637, 0, '221357 Exception Happens'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 221351 AND 221400
