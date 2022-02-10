--rdt_1819ExtVal07
execute rdt.rdtdropmsg 142351, 142400	

execute rdt.rdtAddMsg 142351, 10, '42351^Over MaxPallet',    'us_english', 1819
execute rdt.rdtAddMsg 142352, 10, '42352^Over MaxPallet',    'us_english', 1819

select * from rdt.rdtmsg (nolock) where message_id between 142351 AND 142400	
