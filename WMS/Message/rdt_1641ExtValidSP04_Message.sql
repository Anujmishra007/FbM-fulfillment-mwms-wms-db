-- rdt_1641ExtValidSP04
execute rdt.rdtDropMsg 101051 , 101100

execute rdt.rdtAddMsg 101051, 10, '01051^PALLET CLOSED',    'us_english'
execute rdt.rdtAddMsg 101052, 10, '01052^INV CARTON ID',    'us_english'
execute rdt.rdtAddMsg 101053, 10, '01053^CARTON SCAN B4',   'us_english'
execute rdt.rdtAddMsg 101054, 10, '01054^WRONG ROUTE',      'us_english'
execute rdt.rdtAddMsg 101055, 10, '01055^INV FIELD NAME',   'us_english'
execute rdt.rdtAddMsg 101056, 10, '01056^INV FIELD TYPE',   'us_english'
execute rdt.rdtAddMsg 101057, 10, '01057^VALUE REQUIRED',   'us_english'
execute rdt.rdtAddMsg 101058, 10, '01058^INV ROUTE CODE',   'us_english'

--WMS15617
   execute rdt.rdtAddMsg 101059, 10, '01059^OrderinMultiID',   'us_english'
   execute rdt.rdtAddMsg 101060, 10, '01060^OrderNotPacked',   'us_english'
   execute rdt.rdtAddMsg 101061, 10, '01061^CARTON SCAN B4',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 101051 and 101100