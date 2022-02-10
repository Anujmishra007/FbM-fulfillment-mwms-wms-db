-- rdt_593PreRecv01
exec rdt.rdtDropMsg 102601, 102650

execute rdt.rdtAddMsg 102601, 10, '02601^Need ASN      ', 'us_english', 593
execute rdt.rdtAddMsg 102602, 10, '02602^ASN not exists', 'us_english', 593
execute rdt.rdtAddMsg 102603, 10, '02603^Diff facility ', 'us_english', 593
execute rdt.rdtAddMsg 102604, 10, '02604^Diff storer   ', 'us_english', 593
execute rdt.rdtAddMsg 102605, 10, '02605^Need Line/SKU ', 'us_english', 593
execute rdt.rdtAddMsg 102606, 10, '02606^Line NotInASN ', 'us_english', 593
execute rdt.rdtAddMsg 102607, 10, '02607^LabelPrnterReq', 'us_english', 593
execute rdt.rdtAddMsg 102608, 10, '02608^DWNOTSetup    ', 'us_english', 593
execute rdt.rdtAddMsg 102609, 10, '02609^TgetDB Not Set', 'us_english', 593
execute rdt.rdtAddMsg 102610, 10, '02610 Invalid SKU',    'us_english', 593
execute rdt.rdtAddMsg 102611, 10, '02611 MultiSKUBarcod', 'us_english', 593
execute rdt.rdtAddMsg 102612, 10, '02612 SKU NotInASN',   'us_english', 593
execute rdt.rdtAddMsg 102613, 10, '02613 EitherLine/SKU', 'us_english', 593


