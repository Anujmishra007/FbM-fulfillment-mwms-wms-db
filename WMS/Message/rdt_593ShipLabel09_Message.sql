--rdt_593ShipLabel09
execute rdt.rdtdropmsg 114001 , 114050

execute rdt.rdtAddMsg 114001, 10, '14001^VALUE REQUIRED',   'us_english', 593
execute rdt.rdtAddMsg 114002, 10, '14002^INVALID ORDERS',   'us_english', 593
execute rdt.rdtAddMsg 114003, 10, '14003^ORD NOT ALLOC',    'us_english', 593
execute rdt.rdtAddMsg 114004, 10, '14004^NO SHIPPERKEY',    'us_english', 593
execute rdt.rdtAddMsg 114005, 10, '14005^INV CARTON NO',    'us_english', 593
execute rdt.rdtAddMsg 114006, 10, '14006^LabelPrnterReq',   'us_english', 593

select * from rdt.rdtmsg (nolock) where message_id between 114001 AND 114050
