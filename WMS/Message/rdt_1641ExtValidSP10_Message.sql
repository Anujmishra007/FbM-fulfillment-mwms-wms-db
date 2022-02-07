--rdt_1641ExtValidSP10 

execute rdt.rdtDropMsg 148201 , 148250

execute rdt.rdtAddMsg 148201, 10, '48201^PALLET CLOSED',    'us_english', 1641
execute rdt.rdtAddMsg 148202, 10, '48202^CARTON SCAN B4',   'us_english', 1641
execute rdt.rdtAddMsg 148203, 10, '48203^CARTON SCAN B4',   'us_english', 1641
execute rdt.rdtAddMsg 148204, 10, '48204^WRONG ROUTE',      'us_english', 1641
execute rdt.rdtAddMsg 148205, 10, '48205^INV FIELD NAME',   'us_english', 1641
execute rdt.rdtAddMsg 148206, 10, '48206^INV FIELD TYPE',   'us_english', 1641
execute rdt.rdtAddMsg 148207, 10, '48207^VALUE REQUIRED',   'us_english', 1641
execute rdt.rdtAddMsg 148208, 10, '48208^INV ROUTE CODE',   'us_english', 1641

select * from rdt.rdtmsg (nolock) where message_id between 148201 and 148250