--rdt_1841PrePltSort01
exec rdt.rdtDropMsg 147801 , 147850

execute rdt.rdtAddMsg 147801, 10, '47801^UCC Scanned',      'us_english', 1841
execute rdt.rdtAddMsg 147802, 10, '47802^Ins LOG Fail',     'us_english', 1841
execute rdt.rdtAddMsg 147803, 10, '47803^Upd LOG Fail',     'us_english', 1841
execute rdt.rdtAddMsg 147804, 10, '47804^Plt NoMixSKU',     'us_english', 1841
execute rdt.rdtAddMsg 147805, 10, '47805^> MaxPltMixSKU',   'us_english', 1841
execute rdt.rdtAddMsg 147806, 10, '47806^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 147807, 10, '47807^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 147808, 10, '47808^MaxPltCnt Err',    'us_english', 1841
execute rdt.rdtAddMsg 147809, 10, '47809^Pallet Closed',    'us_english', 1841
execute rdt.rdtAddMsg 147810, 10, '47810^DEL UCC Err',      'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 147801 AND 147850


