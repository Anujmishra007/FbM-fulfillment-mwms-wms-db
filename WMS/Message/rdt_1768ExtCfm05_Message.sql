-- rdt_1768ExtCfm05
exec rdt.rdtDropMsg 241451 , 241500

execute rdt.rdtAddMsg 241451, 10, '241451 Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 241452, 10, '241452 Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 241453, 10, '241453 Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 241454, 10, '241454 Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 241455, 10, '241455 GetKey Fail  ',   'us_english', 1768
execute rdt.rdtAddMsg 241456, 10, '241456 Ins CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 241457, 10, '241457Upd CCDateFail',   'us_english', 1768
execute rdt.rdtAddMsg 241458, 10, '241458Upd CCDateFail',   'us_english', 1768
execute rdt.rdtAddMsg 241459, 10, '241459Upd CCDateFail',   'us_english', 1768
execute rdt.rdtAddMsg 241460, 10, '241460 Ins CCDetFail',   'us_english', 1768

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 241451 AND 241500

