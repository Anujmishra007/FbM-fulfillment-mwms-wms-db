-- rdtfnc_ReceiveByShipmentID
-- exec rdt.rdtDropMsg 80401 , 80450

execute rdt.rdtAddMsg 80401, 10, '80401^ShipID Is Req',   'us_english', 589
execute rdt.rdtAddMsg 80402, 10, '80402^ASN Not Found',   'us_english', 589
execute rdt.rdtAddMsg 80403, 10, '80403^ASN Is closed',   'us_english', 589
execute rdt.rdtAddMsg 80404, 10, '80404^Wrong Facility',  'us_english', 589
execute rdt.rdtAddMsg 80405, 10, '80405^Carton Is Req',   'us_english', 589
execute rdt.rdtAddMsg 80406, 10, '80406^ToLOC Is Req',    'us_english', 589
execute rdt.rdtAddMsg 80407, 10, '80407^ASN Not Found',   'us_english', 589
execute rdt.rdtAddMsg 80408, 10, '80408^ASN Is closed',   'us_english', 589
execute rdt.rdtAddMsg 80409, 10, '80409^Upd ASN Fail',    'us_english', 589
execute rdt.rdtAddMsg 80410, 10, '80410^SKU Is Req',      'us_english', 589
execute rdt.rdtAddMsg 80411, 10, '80411^Invalid SKU',     'us_english', 589
execute rdt.rdtAddMsg 80412, 10, '80412^Invalid Qty',     'us_english', 589
execute rdt.rdtAddMsg 80413, 10, '80413^OPTION req',      'us_english', 589
execute rdt.rdtAddMsg 80414, 10, '80414^Invalid OPTION',  'us_english', 589
execute rdt.rdtAddMsg 80415, 10, '80415^OPTION req',      'us_english', 589
execute rdt.rdtAddMsg 80416, 10, '80416^Invalid OPTION',  'us_english', 589
execute rdt.rdtAddMsg 80417, 10, '80417^Upd ASN Fail',    'us_english', 589
execute rdt.rdtAddMsg 80418, 10, '80418^OPTION req',      'us_english', 589
execute rdt.rdtAddMsg 80419, 10, '80419^Invalid OPTION',  'us_english', 589
execute rdt.rdtAddMsg 80420, 10, '80420^Rcpt Ctn Fail',   'us_english', 589
execute rdt.rdtAddMsg 80421, 10, '80421^Invalid LOC',     'us_english', 589
execute rdt.rdtAddMsg 80422, 10, '80422^Diff Facility',   'us_english', 589
execute rdt.rdtAddMsg 80423, 10, '80423^DUP OPEN ASN',    'us_english', 589
execute rdt.rdtAddMsg 80424, 10, '80424^GetRight Fail',   'us_english', 589
execute rdt.rdtAddMsg 80425, 10, '80425^Ins TR3 Fail',    'us_english', 589
execute rdt.rdtAddMsg 80426, 10, '80426^Double Scan',     'us_english', 589
execute rdt.rdtAddMsg 80427, 10, '80427^Carton Closed',   'us_english', 589
