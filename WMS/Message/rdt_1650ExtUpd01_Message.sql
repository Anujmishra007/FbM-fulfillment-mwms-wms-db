--rdt_1650ExtUpd01
execute rdt.rdtdropmsg 53801 , 53850

execute rdt.rdtAddMsg 53801, 10, '53801^PALLET ID REQ',   'us_english', 1650
execute rdt.rdtAddMsg 53802, 10, '53802^GET RFKEY FAIL',  'us_english', 1650
execute rdt.rdtAddMsg 53803, 10, '53803^LOCK PDTL FAIL',  'us_english', 1650
execute rdt.rdtAddMsg 53804, 10, '53804^LOSE ID FAIL',    'us_english', 1650
execute rdt.rdtAddMsg 53805, 10, '53805^REL PDTL FAIL',   'us_english', 1650
execute rdt.rdtAddMsg 53806, 10, '53806^INSSCN2TRKFAIL',  'us_english', 1650
execute rdt.rdtAddMsg 53807, 10, '53807^CLOSE LANE ERR',  'us_english', 1650

-- (james03)
execute rdt.rdtAddMsg 53808, 10, '53808^UNHOLD ID FAIL',  'us_english', 1650


select * from rdt.rdtmsg (nolock) where message_id between 53801 and 53850

