--rdt_830GetTask06
execute rdt.rdtdropmsg 277501, 277550

execute rdt.rdtAddMsg 277501, 10, '277501NoMoreTask    ', 'us_english', 830, 0, '277501: No more task'
execute rdt.rdtAddMsg 277502, 10, '277502NoQtyFound    ', 'us_english', 830, 0, '277502: No QTY found for SKU at LOC'

select * from rdt.rdtmsg (nolock) where message_id between 277501 and 277550
