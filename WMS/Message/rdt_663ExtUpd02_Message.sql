-- rdt_663ExtUpd02
-- 279601 - 279650
-- FCR-16001

EXECUTE rdt.rdtDropMsg 279601, 279650

EXECUTE rdt.rdtAddMsg 279601, 10, '279601UpdKitFail    ', 'us_english', 663, 0, '279601 Update Kit fail'
EXECUTE rdt.rdtAddMsg 279602, 10, '279602UpdKitFail    ', 'us_english', 663, 0, '279602 Update Kit fail'
EXECUTE rdt.rdtAddMsg 279603, 10, '279603UpdKitFail    ', 'us_english', 663, 0, '279603 Update Kit fail'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE message_id BETWEEN 279601 AND 279650
