-- FCR-6060
-- rdt_1767ExtOpt01
exec rdt.rdtDropMsg 241751 , 241800

execute rdt.rdtAddMsg 241751, 10, '241751 GetKey Fail  ',   'us_english', 1767
execute rdt.rdtAddMsg 241752, 10, '241752 Ins AdjHdr Er',   'us_english', 1767
execute rdt.rdtAddMsg 241753, 10, '241753 Ins AdjDtl Er',   'us_english', 1767
execute rdt.rdtAddMsg 241754, 10, '241754 FinalizeAdJEr',   'us_english', 1767
execute rdt.rdtAddMsg 241755, 10, '241755 Upd TaskDt Er',   'us_english', 1767
execute rdt.rdtAddMsg 241756, 10, '241756 UPD ALERT Err',   'us_english', 1767
execute rdt.rdtAddMsg 241757, 10, '241757 FinalizeCCDEr',   'us_english', 1767
execute rdt.rdtAddMsg 241758, 10, '241758 MoveUCCFail',     'us_english', 1767
execute rdt.rdtAddMsg 241759, 10, '241759 MoveUCCFail',     'us_english', 1767

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 241751 AND 241800

