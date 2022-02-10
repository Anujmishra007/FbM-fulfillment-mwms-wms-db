-- rdt_593Print09 
execute rdt.rdtDropMsg 105001 , 105050

execute rdt.rdtAddMsg 105001, 10, '05001^ORDERKEY REQ',     'us_english'
execute rdt.rdtAddMsg 105002, 10, '05002^INV ORDERS',       'us_english'
execute rdt.rdtAddMsg 105003, 10, '05003^ORD NOT ALLOC',    'us_english'
execute rdt.rdtAddMsg 105004, 10, '05004^LabelPrnterReq',   'us_english'
execute rdt.rdtAddMsg 105005, 10, '05005^DWNOTSetup',       'us_english'
execute rdt.rdtAddMsg 105006, 10, '05006^TgetDB Not Set',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 105001 and 105050