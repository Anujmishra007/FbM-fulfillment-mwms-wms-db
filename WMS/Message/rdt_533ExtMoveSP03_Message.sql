--rdt_533ExtMoveSP03
EXEC rdt.rdtDropMsg 206001 , 206050		

execute rdt.rdtAddMsg 206001, 10, '206001 InsPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 206002, 10, '206002 UpdPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 206003, 10, '206003 DelPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 206004, 10, '206004 UpdPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 206005, 10, '206005 OffsetError',      'us_english', 533
execute rdt.rdtAddMsg 206006, 10, '206006 UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 206007, 10, '206007 DelPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 206008, 10, '206008 InsPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 206009, 10, '206009 UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 206010, 10, '206010 UpdPickDetFail',   'us_english', 533
execute rdt.rdtAddMsg 206011, 10, '206011 UpdPickDetFail',   'us_english', 533

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 206001 AND 206050	
