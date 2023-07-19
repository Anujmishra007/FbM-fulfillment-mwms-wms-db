--rdt_840ExtPackCfm04
execute rdt.rdtdropmsg 200751 , 200800

execute rdt.rdtAddMsg 200751, 10, '200751 GetRightFail ',   'us_english', 840
execute rdt.rdtAddMsg 200752, 10, '200752 AutoMBOLPack ',   'us_english', 840
execute rdt.rdtAddMsg 200753, 10, '200753 ConfPackFail ',   'us_english', 840
execute rdt.rdtAddMsg 200754, 10, '200754 INS COO Fail ',   'us_english', 840
execute rdt.rdtAddMsg 200755, 10, '200755 Ins CtnTrk Er',   'us_english', 840
execute rdt.rdtAddMsg 200756, 10, '200756 Exec ITF Fail',   'us_english', 840
execute rdt.rdtAddMsg 200757, 10, '200757 Upd Trk# Fail',   'us_english', 840
execute rdt.rdtAddMsg 200758, 10, '200758 Exec ITF Fail',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 200751 AND 200800