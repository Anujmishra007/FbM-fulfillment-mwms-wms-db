--rdt_1641CaptureInf01
execute rdt.rdtdropmsg 153451 , 153500

execute rdt.rdtAddMsg 153451, 10, '53451^Wrong Plt Type',    'us_english', 1641
execute rdt.rdtAddMsg 153452, 10, '53452^Upd PltType Er',    'us_english', 1641


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 153451 AND 153500