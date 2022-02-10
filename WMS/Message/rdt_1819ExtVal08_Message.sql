--rdt_1819ExtVal08
execute rdt.rdtdropmsg 151301, 151350	

execute rdt.rdtAddMsg 151301, 10, '51301^Pending Putaway',  'us_english', 1819
execute rdt.rdtAddMsg 151302, 10, '51302^Task Exists',      'us_english', 1819
execute rdt.rdtAddMsg 151303, 10, '51303^ID In Transit',    'us_english', 1819

select * from rdt.rdtmsg (nolock) where message_id between 151301 AND 151350	
