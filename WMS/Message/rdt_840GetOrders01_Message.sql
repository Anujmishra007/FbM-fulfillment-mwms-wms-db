--rdt_840GetOrders01
execute rdt.rdtdropmsg 154551, 154600

execute rdt.rdtAddMsg 154551, 10, '54551^NO ORDERS',        'us_english', 840
execute rdt.rdtAddMsg 154552, 10, '54552^NEED SORTATION',   'us_english', 840
execute rdt.rdtAddMsg 154553, 10, '54553^NEED SORTATION',   'us_english', 840


select * from rdt.rdtmsg (nolock) where message_id between 154551 and 154600