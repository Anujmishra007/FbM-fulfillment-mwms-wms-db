--rdt_593IT6901
--execute rdt.rdtDropMsg 132801 , 132850

execute rdt.rdtAddMsg 132801, 10, '32801^LocReq',    'us_english'
execute rdt.rdtAddMsg 132802, 10, '32802^InvalidLoc',    'us_english'
execute rdt.rdtAddMsg 132803, 10, '32803^LabelPrnterReq',    'us_english'
execute rdt.rdtAddMsg 132804, 10, '32804^LabelReq',    'us_english'
execute rdt.rdtAddMsg 132805, 10, '32805^QtyReq',    'us_english'
execute rdt.rdtAddMsg 132806, 10, '32806^InvalidQty',    'us_english'

--WMS-11076
execute rdt.rdtAddMsg 132807, 10, '32807^ID Req',     'us_english', 593
execute rdt.rdtAddMsg 132808, 10, '32808^Invalid ID', 'us_english', 593


