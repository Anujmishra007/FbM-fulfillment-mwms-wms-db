-- rdt_1812ExtScn05_Confirm
execute rdt.rdtDropMsg 229001 , 229050

execute rdt.rdtAddMsg 229001, 10, '229001 INSPLTHdrFail',    'us_english', 1812
execute rdt.rdtAddMsg 229002, 10, '229002 INSPLTDtlFail',    'us_english', 1812
execute rdt.rdtAddMsg 229003, 10, '229003 UPDPLTHdrFail',    'us_english', 1812
execute rdt.rdtAddMsg 229004, 10, '229004 INS MBOL Fail',    'us_english', 1812
execute rdt.rdtAddMsg 229005, 10, '229005INS MBDtl Fail',    'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 229001 AND 229050

