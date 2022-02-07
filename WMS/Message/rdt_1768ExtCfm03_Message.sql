--rdt_1768ExtCfm03
exec rdt.rdtDropMsg 167001 , 167050

execute rdt.rdtAddMsg 167001, 10, '167001Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 167002, 10, '167002Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 167003, 10, '167003Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 167004, 10, '167004Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 167005, 10, '167005GetKey Fail',     'us_english', 1768
execute rdt.rdtAddMsg 167006, 10, '167006InsCCDetFail',    'us_english', 1768
execute rdt.rdtAddMsg 167007, 10, '167007Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 167008, 10, '167008Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 167009, 10, '167009Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 167010, 10, '167010Upd CCDateFail',  'us_english', 1768

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 167001 AND 167050

