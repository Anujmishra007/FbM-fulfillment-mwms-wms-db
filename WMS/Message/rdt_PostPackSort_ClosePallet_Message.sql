--rdt_PostPackSort_ClosePallet
rdt.rdtDropMsg 144401 , 144450

execute rdt.rdtAddMsg 144401, 10, '44401^Setup Lane',       'us_english', 1837
execute rdt.rdtAddMsg 144402, 10, '44402^GetKey Fail',      'us_english', 1837
execute rdt.rdtAddMsg 144403, 10, '44403^CreateMVTaskEr',   'us_english', 1837
execute rdt.rdtAddMsg 144404, 10, '44404^No Pack&Hold',     'us_english', 1837
execute rdt.rdtAddMsg 144405, 10, '44405^GetKey Fail',      'us_english', 1837
execute rdt.rdtAddMsg 144406, 10, '44406^CreatePATaskEr',   'us_english', 1837


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 144401 AND 139250

