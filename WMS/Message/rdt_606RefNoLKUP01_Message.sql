--rdt_606RefNoLKUP01
execute rdt.rdtdropmsg 150951 , 151000

execute rdt.rdtAddMsg 150951, 10, '50951^Max 3 RefField',   'us_english', 606
execute rdt.rdtAddMsg 150952, 10, '50952^Invalid RefNo',    'us_english', 606
execute rdt.rdtAddMsg 150953, 10, '50953^Multi ASN',        'us_english', 606

select * from rdt.rdtmsg (nolock) where message_id between 150951 AND 151000
