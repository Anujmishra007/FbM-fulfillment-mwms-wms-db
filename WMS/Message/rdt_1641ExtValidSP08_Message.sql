--rdt_1641ExtValidSP08
execute rdt.rdtDropMsg 143601 , 143650

execute rdt.rdtAddMsg 143601, 10, '43601^PALLET CLOSED',    'us_english', 1641
execute rdt.rdtAddMsg 143602, 10, '43602^INV CARTON ID',    'us_english', 1641
execute rdt.rdtAddMsg 143603, 10, '43603^CARTON SCAN B4',   'us_english', 1641
execute rdt.rdtAddMsg 143604, 10, '43604^CARTON SCAN B4',   'us_english', 1641
execute rdt.rdtAddMsg 143605, 10, '43605^WRONG ROUTE',      'us_english', 1641
execute rdt.rdtAddMsg 143606, 10, '43606^INV FIELD NAME',   'us_english', 1641
execute rdt.rdtAddMsg 143607, 10, '43607^INV FIELD TYPE',   'us_english', 1641
execute rdt.rdtAddMsg 143608, 10, '43608^VALUE REQUIRED',   'us_english', 1641
execute rdt.rdtAddMsg 143609, 10, '43609^INV ROUTE CODE',   'us_english', 1641

--WMS14187
execute rdt.rdtAddMsg 143610, 10, '43610^LiquidItem', 'us_english', 1641
execute rdt.rdtAddMsg 143611, 10, '43611^NonLiquidItem', 'us_english', 1641
execute rdt.rdtAddMsg 143612, 10, '43612^WrongPallet', 'us_english', 1641
execute rdt.rdtAddMsg 143613, 10, '143613WrongCarrier', 'us_english', 1641


select * from rdt.rdtmsg (nolock) where message_id between 143601 and 143650