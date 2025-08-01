--rdt_1812CfmExtUpd04
execute rdt.rdtdropmsg 221751, 221800

execute rdt.rdtAddMsg 221751, 10, '221751InsPHdrFail   ', 'us_english', 1812
execute rdt.rdtAddMsg 221752, 10, '221752InsPackDtlFail', 'us_english', 1812
execute rdt.rdtAddMsg 221753, 10, '221753UpdPackDtlFail', 'us_english', 1812
execute rdt.rdtAddMsg 221754, 10, '221754UPDPackInfFail', 'us_english', 1812
execute rdt.rdtAddMsg 221755, 10, '221755INSPackInfFail', 'us_english', 1812
execute rdt.rdtAddMsg 221756, 10, '221756 UPD UCC FAIL ', 'us_english', 1812
execute rdt.rdtAddMsg 221757, 10, '221757ShipLabel fail', 'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 221751 AND 221800
