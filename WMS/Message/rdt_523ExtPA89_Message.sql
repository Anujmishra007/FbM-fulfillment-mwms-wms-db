-- FCR-10232
EXECUTE rdt.rdtDropMsg 262351, 262400

EXECUTE rdt.rdtAddMsg 262351, 10, '262351 NoPutawayZone',         'us_english', 523, 0, '262351 No PutawayZone is setup'
EXECUTE rdt.rdtAddMsg 262352, 10, '262352 ExecSPFail',            'us_english', 523, 0, '262352 Execute rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 262353, 10, '262353 NoQtyToMove',           'us_english', 523, 0, '262353 No quantity to move into suggested location'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 262351 AND 262400