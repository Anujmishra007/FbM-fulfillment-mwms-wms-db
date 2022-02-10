-- rdt_TM_Assist_Putaway_GetSuggestLOC
rdt.rdtDropMsg 143901 , 143950

execute rdt.rdtAddMsg 143901, 10, '43901^NoSuitableLOC ',    'us_english', 1815
execute rdt.rdtAddMsg 143902, 10, '43902^UPD Task Fail ',    'us_english', 1815


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143901 AND 143950