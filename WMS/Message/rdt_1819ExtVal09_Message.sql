--rdt_1819ExtVal09
execute rdt.rdtdropmsg 151951 , 152000		

execute rdt.rdtAddMsg 151951, 10, '51951^OVER MAXSKU',   'us_english', 1819

select * from rdt.rdtmsg (nolock) where message_id between 151951 AND 152000		
