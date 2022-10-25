--rdt_606RefNoLKUP02
execute rdt.rdtdropmsg 191001  , 191050

execute rdt.rdtAddMsg 191001, 10, '191001Max 3 RefField',   'us_english', 606
execute rdt.rdtAddMsg 191002, 10, '191002Invalid RefNo',    'us_english', 606
execute rdt.rdtAddMsg 191003, 10, '191003Multi ASN',        'us_english', 606
execute rdt.rdtAddMsg 191004, 10, '191004ASNNotFound',        'us_english', 606

select * from rdt.rdtmsg (nolock) where message_id between 191001 AND 191050
