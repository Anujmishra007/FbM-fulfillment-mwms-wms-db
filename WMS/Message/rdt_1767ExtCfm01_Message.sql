-- rdt_1767ExtCfm01
exec rdt.rdtDropMsg 241701 , 241750

execute rdt.rdtAddMsg 241701, 10, '241701 Upd CCDetFail',   'us_english', 1767
execute rdt.rdtAddMsg 241702, 10, '241702 Ins CCDetFail',   'us_english', 1767
execute rdt.rdtAddMsg 241703, 10, '241703 Upd CCDetFail',   'us_english', 1767
execute rdt.rdtAddMsg 241704, 10, '241704 Upd CCDetFail',   'us_english', 1767
execute rdt.rdtAddMsg 241705, 10, '241705 GetKey Fail  ',   'us_english', 1767
execute rdt.rdtAddMsg 241706, 10, '241706 Ins CCDetFail',   'us_english', 1767
execute rdt.rdtAddMsg 241707, 10, '241707Upd CCDateFail',   'us_english', 1767
execute rdt.rdtAddMsg 241708, 10, '241708Upd CCDateFail',   'us_english', 1767
execute rdt.rdtAddMsg 241709, 10, '241709Upd CCDateFail',   'us_english', 1767
execute rdt.rdtAddMsg 241710, 10, '241710 GetKey Fail  ',   'us_english', 1767
execute rdt.rdtAddMsg 241711, 10, '241711 Ins CCDetFail',   'us_english', 1767

-- UWP-40373
execute rdt.rdtAddMsg 241712, 10, '241712 DelCCDetFail',    'us_english', 1767, 0, '241712 Delete CC Detail Failed'
execute rdt.rdtAddMsg 241713, 10, '241713 DelCCFail',       'us_english', 1767, 0, '241713 Delete CC Failed'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 241701 AND 241750

