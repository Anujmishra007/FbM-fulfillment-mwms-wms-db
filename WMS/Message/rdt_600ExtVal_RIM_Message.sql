rdt_600ExtVal_RIM

execute rdt.rdtdropmsg  218386
execute rdt.rdtdropmsg  218387
execute rdt.rdtdropmsg  218388
execute rdt.rdtdropmsg  218389

execute rdt.rdtAddMsg 218386, 10, '218386 Lottable01 Not Exist',  'us_english', 600
execute rdt.rdtAddMsg 218387, 10, '218387 Lottable01/04 Mismatch',  'us_english', 600
execute rdt.rdtAddMsg 218388, 10, '218388 LPN Used Diff PO',  'us_english', 600
execute rdt.rdtAddMsg 218389, 10, '218389 Over Receipt',  'us_english', 600


select * from rdt.rdtmsg (nolock) where message_id in ( 218386, 218387, 218388, 218389)