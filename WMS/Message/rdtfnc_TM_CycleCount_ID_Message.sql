/********************************************************
rdtfnc_TM_CycleCount_ID_Message

EXECUTE rdt.rdtDropMsg 139801 , 139850
********************************************************/

EXECUTE rdt.rdtAddMsg 139801 ,10, '139801 CTN COUNT REQ', 'us_english', 1769
EXECUTE rdt.rdtAddMsg 139802 ,10, '139802 BAD CTN COUNT', 'us_english', 1769
EXECUTE rdt.rdtAddMsg 139803 ,10, '139803 ID REQUIRED',   'us_english', 1769
EXECUTE rdt.rdtAddMsg 139804 ,10, '139804 NO CCD FOUND',  'us_english', 1769

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 139801 AND 139850
