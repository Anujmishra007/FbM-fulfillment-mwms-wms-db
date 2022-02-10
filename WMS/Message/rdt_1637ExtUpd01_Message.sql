-- rdt_1637ExtUpd01
exec rdt.rdtDropMsg 98401 , 98450

execute rdt.rdtAddMsg 98401, 10, '98401^PALLET ID REQ',   'us_english', 1637
execute rdt.rdtAddMsg 98402, 10, '98402^GET RFKEY FAIL',  'us_english', 1637
execute rdt.rdtAddMsg 98403, 10, '98403^LOCK PDTL FAIL',  'us_english', 1637
execute rdt.rdtAddMsg 98404, 10, '98404^LOSE ID FAIL',    'us_english', 1637
execute rdt.rdtAddMsg 98405, 10, '98405^REL PDTL FAIL',   'us_english', 1637
execute rdt.rdtAddMsg 98406, 10, '98406^INSSCN2TRKFAIL',  'us_english', 1637
execute rdt.rdtAddMsg 98407, 10, '98407^UNHOLD ID FAIL',  'us_english', 1637

-- (james01)
execute rdt.rdtAddMsg 98408, 10, '98408^UPD QTY FAIL',    'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 98401 and 98450

