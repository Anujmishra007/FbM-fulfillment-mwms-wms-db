--rdt_840ExtInsPack01
execute rdt.rdtdropmsg 100801 , 100850


execute rdt.rdtAddMsg 100801, 10, '00801^INVALID MBOL',  'us_english', 922
execute rdt.rdtAddMsg 100802, 10, '00802^MBOL CLOSED',   'us_english', 922
execute rdt.rdtAddMsg 100803, 10, '00803^AND MANIFEST',  'us_english', 922
execute rdt.rdtAddMsg 100804, 10, '00804^PRINTED',       'us_english', 922
execute rdt.rdtAddMsg 100805, 10, '00805^LABEL SCANNED', 'us_english', 922
execute rdt.rdtAddMsg 100806, 10, '00806^BEFORE IN',     'us_english', 922
execute rdt.rdtAddMsg 100807, 10, '00807^MBOLKEY',       'us_english', 922
execute rdt.rdtAddMsg 100808, 10, '00808^LABEL SCANNED', 'us_english', 922
execute rdt.rdtAddMsg 100809, 10, '00809^BEFORE IN',     'us_english', 922
execute rdt.rdtAddMsg 100810, 10, '00810^MBOLKEY',       'us_english', 922

select * from rdt.rdtmsg (nolock) where message_id between 100801 and 100850
