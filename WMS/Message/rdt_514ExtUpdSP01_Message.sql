--rdt_514ExtUpdSP01
exec rdt.rdtDropMsg 136701 , 136750

execute rdt.rdtAddMsg 136701 ,10, '36701^InsPackDtlFail',   'us_english',514
execute rdt.rdtAddMsg 136702 ,10, '36702^DelPackDtlFail',   'us_english',514
execute rdt.rdtAddMsg 136703 ,10, '36703^Upd Pallet Err',   'us_english',514
execute rdt.rdtAddMsg 136704 ,10, '36704^Upd Pallet Err',   'us_english',514

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136701 AND 136750
