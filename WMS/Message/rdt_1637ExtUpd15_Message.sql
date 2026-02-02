-- rdt_1637ExtUpd15
--FCR-8619
execute rdt.rdtdropmsg 249751, 249800

execute rdt.rdtAddMsg 249751, 10, '249751 UpdCntDtlFail ', 'us_english', 1637, 0, '249751 Update Container Details Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 249751 AND 249800
