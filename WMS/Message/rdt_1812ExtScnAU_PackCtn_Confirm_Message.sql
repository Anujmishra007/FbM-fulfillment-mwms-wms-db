-- 269501 - 269550

execute rdt.rdtDropMsg 269501 , 269550

execute rdt.rdtAddMsg 269501, 10, '269501 InsPHdrFail',         'us_english', 1812
execute rdt.rdtAddMsg 269502, 10, '269502 GenLabelNoFail',      'us_english', 1812
execute rdt.rdtAddMsg 269503, 10, '269503 GenLabelNoFail',      'us_english', 1812
execute rdt.rdtAddMsg 269504, 10, '269504 INSPackDtlFail',      'us_english', 1812
execute rdt.rdtAddMsg 269505, 10, '269505 UPDPackDtlFail',      'us_english', 1812
execute rdt.rdtAddMsg 269506, 10, '269506 INS PDInfoFail',      'us_english', 1812
execute rdt.rdtAddMsg 269507, 10, '269507 UPD PDInfoFail',      'us_english', 1812
execute rdt.rdtAddMsg 269508, 10, '269508 INSPackInfFail',      'us_english', 1812
execute rdt.rdtAddMsg 269509, 10, '269509 UPDPackInfFail',      'us_english', 1812
execute rdt.rdtAddMsg 269510, 10, '269510 UPDTaskDtlFail',      'us_english', 1812
execute rdt.rdtAddMsg 269511, 10, '269511 UPDPickDtlFail',      'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 269501 AND 269550
