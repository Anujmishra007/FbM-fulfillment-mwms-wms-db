--rdt_1663DecodeTK04
execute rdt.rdtdropmsg 153501 , 153550

execute rdt.rdtAddMsg 153501, 10, '50951^Max 5 RefField',   'us_english', 1663
execute rdt.rdtAddMsg 153502, 10, '50952^Multi Orders',     'us_english', 1663
execute rdt.rdtAddMsg 153503, 10, '50953^No Order Found',   'us_english', 1663

select * from rdt.rdtmsg (nolock) where message_id between 153501 AND 153550
