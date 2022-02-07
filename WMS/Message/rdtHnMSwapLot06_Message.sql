-- rdtHnMSwapLot06
execute rdt.rdtDropMsg 146101 , 146150

execute rdt.rdtAddMsg 146101, 10, '46101^INVALID ORDERS',      'us_english', 840
execute rdt.rdtAddMsg 146102, 10, '46102^INVALID SKU',         'us_english', 840
execute rdt.rdtAddMsg 146103, 10, '46103^INVALID LOT02',       'us_english', 840
execute rdt.rdtAddMsg 146104, 10, '46104^SKU NOT IN ORD',      'us_english', 840
execute rdt.rdtAddMsg 146105, 10, '46105^INVALID LABEL',       'us_english', 840
execute rdt.rdtAddMsg 146106, 10, '46106^COD ORDERS',          'us_english', 840
execute rdt.rdtAddMsg 146107, 10, '46107^SKU OVERPACKED',      'us_english', 840
execute rdt.rdtAddMsg 146108, 10, '46108^UPDPKDET Fail',       'us_english', 840
execute rdt.rdtAddMsg 146109, 10, '46109^NO LOT 2 SWAP',       'us_english', 840
execute rdt.rdtAddMsg 146110, 10, '46110^UPDPKDET Failed',     'us_english', 840
execute rdt.rdtAddMsg 146111, 10, '46111^NO LOT 2 SWAP',       'us_english', 840
execute rdt.rdtAddMsg 146112, 10, '46112^NO LOT 2 SWAP',       'us_english', 840
execute rdt.rdtAddMsg 146113, 10, '46113^NO LOT 2 SWAP',       'us_english', 840
execute rdt.rdtAddMsg 146114, 10, '46114^SWAP LOT FAIL',       'us_english', 840
execute rdt.rdtAddMsg 146115, 10, '46115^SWAP LOT FAIL',       'us_english', 840
execute rdt.rdtAddMsg 146116, 10, '46116^SWAP LOT FAIL',       'us_english', 840
execute rdt.rdtAddMsg 146117, 10, '46117^NO INV 2 SWAP',       'us_english', 840
execute rdt.rdtAddMsg 146118, 10, '46118^UpdLog Failed',       'us_english', 840
execute rdt.rdtAddMsg 146119, 10, '46119^InsLog Failed',       'us_english', 840
execute rdt.rdtAddMsg 146120, 10, '46120^InsPKHDR Failed',     'us_english', 840
execute rdt.rdtAddMsg 146121, 10, '46121^NO TRACKING #',       'us_english', 840
execute rdt.rdtAddMsg 146122, 10, '46122^NO TRACKING #',       'us_english', 840
execute rdt.rdtAddMsg 146123, 10, '46123^ASSIGN TRK# ER',      'us_english', 840
execute rdt.rdtAddMsg 146124, 10, '46124^ASSIGN TRK# ER',      'us_english', 840
execute rdt.rdtAddMsg 146125, 10, '46125^UPDPKDET Failed',     'us_english', 840
execute rdt.rdtAddMsg 146126, 10, '46126^GET LABEL Fail',      'us_english', 840
execute rdt.rdtAddMsg 146127, 10, '46127^INSPKDET Failed',     'us_english', 840
execute rdt.rdtAddMsg 146128, 10, '46128^INSPKDET Failed',     'us_english', 840



SELECT * FROM RDT.RDTMsg AS r (NOLOCK) WHERE r.Message_ID BETWEEN 146101 AND 146150

