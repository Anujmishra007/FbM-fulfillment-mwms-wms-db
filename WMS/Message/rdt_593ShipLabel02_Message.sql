
-- rdt_593ShipLabel02 
execute rdt.rdtDropMsg 100851 , 100900

execute rdt.rdtAddMsg '100851', 10, '00851^ORDERKEY REQ',   'us_english'
execute rdt.rdtAddMsg '100852', 10, '00852^INV ORDERS',     'us_english'
execute rdt.rdtAddMsg '100853', 10, '00853^ORD NOT ALLOC',  'us_english'
execute rdt.rdtAddMsg '100854', 10, '00854^ORDERS SHIPPED', 'us_english'
execute rdt.rdtAddMsg '100855', 10, '00855^NO PKSLIP NO',   'us_english'
execute rdt.rdtAddMsg '100856', 10, '00856^NO RECORD',      'us_english'
execute rdt.rdtAddMsg '100857', 10, '00857^LABELPRNTERREQ', 'us_english'
execute rdt.rdtAddMsg '100858', 10, '00858^DEL TL2 FAIL',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 100851 AND 100900
