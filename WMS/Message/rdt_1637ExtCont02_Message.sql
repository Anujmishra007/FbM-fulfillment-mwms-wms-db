--rdt_1637ExtCont01
--FCR-8619
EXECUTE rdt.rdtDropMsg 249451, 249500

EXECUTE rdt.rdtAddMsg 249451, 10, '249451 CntKeyNeeded',    'us_english', 1637, 0, '249451 ContainerKey is required'
EXECUTE rdt.rdtAddMsg 249452, 10, '249452 CntNoNeeded',     'us_english', 1637, 0, '249452 ContainerNo is required'
EXECUTE rdt.rdtAddMsg 249453, 10, '249453 SQLException',    'us_english', 1637, 0, '249453 SQL Exception Occurred'
EXECUTE rdt.rdtAddMsg 249454, 10, '249454 GETKEY FAILED',   'us_english', 1637, 0, '249454 Generate ContainerKey Failed'
EXECUTE rdt.rdtAddMsg 249455, 10, '249455 INS CONT FAIL',   'us_english', 1637, 0, '249455 Insert Container Failed'
EXECUTE rdt.rdtAddMsg 249456, 10, '249456 RequiredValueNeeded',   'us_english', 1637, 0, '249456 ContainerKey or ContainerNo is required'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 249451 AND 249500