--rdt_573ExtValSP09WLR

execute rdt.rdtdropmsg 218392, 218393, 218394

execute rdt.rdtAddMsg 218392, 10, '218392 ID already in STORAGE',  'us_english', 573
execute rdt.rdtAddMsg 218393, 10, '218393 Not STAGING LOC',  'us_english', 573
execute rdt.rdtAddMsg 218394, 10, '218394 PO CANT BE MIXED',  'us_english', 573



select * from rdt.rdtmsg (nolock) where message_id in ( 218392,218393,218394)