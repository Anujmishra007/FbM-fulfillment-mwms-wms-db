--rdt_1841PrePltSort01
--FCR-9027
exec rdt.rdtDropMsg 252501 , 252550

execute rdt.rdtAddMsg 252501, 10, '252501^UCC Scanned',      'us_english', 1841
execute rdt.rdtAddMsg 252502, 10, '252502^Ins LOG Fail',     'us_english', 1841
execute rdt.rdtAddMsg 252503, 10, '252503^Upd LOG Fail',     'us_english', 1841
execute rdt.rdtAddMsg 252504, 10, '252504^Plt NoMixSKU',     'us_english', 1841
execute rdt.rdtAddMsg 252505, 10, '252505^> MaxPltMixSKU',   'us_english', 1841
execute rdt.rdtAddMsg 252506, 10, '252506^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 252507, 10, '252507^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 252508, 10, '252508^MaxPltCnt Err',    'us_english', 1841
execute rdt.rdtAddMsg 252509, 10, '252509^Pallet Closed',    'us_english', 1841
execute rdt.rdtAddMsg 252510, 10, '252510^DEL UCC Err',      'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 252501 AND 252550
