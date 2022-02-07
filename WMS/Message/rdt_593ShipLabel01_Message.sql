
-- rdt_593ShipLabel01 
execute rdt.rdtDropMsg 59251 , 59300

execute rdt.rdtAddMsg '59251', 10, '59251^ORDERKEY REQ',    'us_english'
execute rdt.rdtAddMsg '59252', 10, '59252^INV ORDERS',      'us_english'
execute rdt.rdtAddMsg '59253', 10, '59253^ORD NOT ALLOC',   'us_english'
execute rdt.rdtAddMsg '59254', 10, '59254^NO SHIPPERKEY',   'us_english'
execute rdt.rdtAddMsg '59255', 10, '59255^NO PKSLIP NO',    'us_english'
execute rdt.rdtAddMsg '59256', 10, '59256^INV CARTON NO',   'us_english'
execute rdt.rdtAddMsg '59257', 10, '59257^LABELPRNTERREQ',  'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 59251 and 59300
