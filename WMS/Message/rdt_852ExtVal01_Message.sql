--rdt_852ExtVal01
exec rdt.rdtDropMsg  176551  , 176600		

execute rdt.rdtAddMsg 176551, 10, '176551InvalidCode', 'us_english', 852

select * from rdt.rdtmsg (nolock) where message_id between 170251 and 170300



