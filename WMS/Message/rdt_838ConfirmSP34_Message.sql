-- rdt_838ConfirmSP34
-- FCR-12178
execute rdt.rdtDropMsg 269401, 269450

execute rdt.rdtAddMsg 269401, 10, '269401InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 269402, 10, '269402GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 269403, 10, '269403GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 269404, 10, '269404InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 269405, 10, '269405UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 269406, 10, '269406INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 269407, 10, '269407UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 269408, 10, '269408UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 269409, 10, '269409SN QTYNotTally', 'us_english', 838
execute rdt.rdtAddMsg 269410, 10, '269410INSPackSNOFail', 'us_english', 838
execute rdt.rdtAddMsg 269411, 10, '269411SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 269412, 10, '269412DEL TmpSN Fail', 'us_english', 838
execute rdt.rdtAddMsg 269413, 10, '269413Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 269414, 10, '269414Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 269415, 10, '269415INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 269416, 10, '269416SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 269417, 10, '269417INS PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 269418, 10, '269418UPD PDInfoFail', 'us_english', 838

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 269401 AND 269450