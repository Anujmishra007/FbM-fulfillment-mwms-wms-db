--rdt_1841PrePltSort02
exec rdt.rdtDropMsg 165651 , 165700

execute rdt.rdtAddMsg 165651, 10, '65651^UCC Scanned',      'us_english', 1841
execute rdt.rdtAddMsg 165652, 10, '65652^SetupMixSKULoc',   'us_english', 1841
execute rdt.rdtAddMsg 165653, 10, '65653^Setup SKULoc',     'us_english', 1841
execute rdt.rdtAddMsg 165654, 10, '65654^Ins Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 165655, 10, '65655^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 165656, 10, '65656^Pallet Closed',    'us_english', 1841
execute rdt.rdtAddMsg 165657, 10, '65657^Upd PID Fail',     'us_english', 1841
execute rdt.rdtAddMsg 165658, 10, '65658^Upd Log Fail',     'us_english', 1841
execute rdt.rdtAddMsg 165659, 10, '65659^Pallet In Used',   'us_english', 1841
execute rdt.rdtAddMsg 165670, 10, '65670^Receive UCC Er',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 165651 AND 165700

