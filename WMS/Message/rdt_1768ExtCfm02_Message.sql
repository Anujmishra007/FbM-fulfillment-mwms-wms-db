--rdt_1768ExtCfm02
exec rdt.rdtDropMsg 137801 , 137850

execute rdt.rdtAddMsg 137801, 10, '37801^Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 137802, 10, '37802^Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 137803, 10, '37803^Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 137804, 10, '37804^Upd CCDetFail',   'us_english', 1768
execute rdt.rdtAddMsg 137805, 10, '37805^GetKey Fail',     'us_english', 1768
execute rdt.rdtAddMsg 137806, 10, '37806^InsCCDetFail',    'us_english', 1768
execute rdt.rdtAddMsg 137807, 10, '37807^Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 137808, 10, '37808^Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 137809, 10, '37809^Upd CCDateFail',  'us_english', 1768
execute rdt.rdtAddMsg 137810, 10, '37810^Upd CCDateFail',  'us_english', 1768

--WMS-10416 
execute rdt.rdtAddMsg 137811, 10, 'Qty Inconsistent',      'us_english', 1768

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137801 AND 137850

