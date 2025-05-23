--rdt_1836ExtUpd05
--UWP-34990
EXEC rdt.rdtdropmsg 239001 , 239050	

EXECUTE rdt.rdtAddMsg 239001, 10, '239001 UpdTskFail', 'us_english', 1836, 0, '239001 Update ASTCPK task failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 239001 AND 239050