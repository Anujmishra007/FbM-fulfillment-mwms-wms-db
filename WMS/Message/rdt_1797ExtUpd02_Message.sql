-- FCR-11750
EXEC rdt.rdtDropMsg 265451, 265500

EXECUTE rdt.rdtAddMsg 265451 ,10, '265451 UpdTaskDetailFail',     'us_english', 1797, 0, '265451 Update TaskDetail Failed'
EXECUTE rdt.rdtAddMsg 265452 ,10, '265452 BookLocFail',           'us_english', 1797, 0, '265452 Book Putaway PendingMoveIn Failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 265451 AND 265500
