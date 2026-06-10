-- 269451 - 269500

-- rdt_1812ExtScn06
execute rdt.rdtDropMsg 269451 , 269500

execute rdt.rdtAddMsg 269451, 10, '269451^INSPLTHdrFail',      'us_english', 1812
execute rdt.rdtAddMsg 269452, 10, '269452^INSPLTDtlFail',      'us_english', 1812
execute rdt.rdtAddMsg 269453, 10, '269453^UPD PLTDL Err',      'us_english', 1812
execute rdt.rdtAddMsg 269454, 10, '269454^UPDPLTHdrFail',      'us_english', 1812
execute rdt.rdtAddMsg 269455, 10, '269455^INS MBOL Fail',      'us_english', 1812
execute rdt.rdtAddMsg 269456, 10, '269456^INS MBDtl Fail',     'us_english', 1812

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 269451 AND 269500