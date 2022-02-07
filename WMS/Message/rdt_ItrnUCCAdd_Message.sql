--rdt_ItrnUCCAdd
execute rdt.rdtdropmsg 153751 , 153800

execute rdt.rdtAddMsg 153751, 10, '53751^ITRNUCC InsErr',   'us_english', 0

select * from rdt.rdtmsg (nolock) where message_id between 153751 AND 153800
