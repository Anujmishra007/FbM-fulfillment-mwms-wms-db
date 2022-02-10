-- rdt_1580ExtSNVal
execute rdt.rdtDropMsg 109101, 109150

execute rdt.rdtAddMsg 109101, 10, '109101SNO not in ASN', 'us_english', 1580
execute rdt.rdtAddMsg 109102, 10, '109102SNO dup in ASN', 'us_english', 1580
execute rdt.rdtAddMsg 109103, 10, '109103SNO diff SKU  ', 'us_english', 1580
execute rdt.rdtAddMsg 109104, 10, '109104SNO received  ', 'us_english', 1580
execute rdt.rdtAddMsg 109105, 10, '109105SNO not exist ', 'us_english', 1580
execute rdt.rdtAddMsg 109106, 10, '109106SNO NotInOrder', 'us_english', 1580
execute rdt.rdtAddMsg 109107, 10, '109107SNO NotYetShip', 'us_english', 1580
execute rdt.rdtAddMsg 109108, 10, '109108SNO is HOLD   ', 'us_english', 1580
execute rdt.rdtAddMsg 109109, 10, '109109LOC is HOLD   ', 'us_english', 1580
execute rdt.rdtAddMsg 109110, 10, '109110SNO received  ', 'us_english', 1580
execute rdt.rdtAddMsg 109111, 10, '109111SNO received  ', 'us_english', 1580

--WMS-12331
execute rdt.rdtAddMsg 109112, 10, '109112RCV>PALLET Qty', 'us_english', 1580
