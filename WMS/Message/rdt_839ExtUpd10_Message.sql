--rdt_839ExtUpd10
--FCR-9040
EXECUTE rdt.rdtdropmsg 256601 , 256650

EXECUTE rdt.rdtAddMsg 256601, 10, '256601 DelPickSerialNoFail',          'us_english', 839, 0, '256601 Delete PickSerialNo failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 256601 AND 256650
