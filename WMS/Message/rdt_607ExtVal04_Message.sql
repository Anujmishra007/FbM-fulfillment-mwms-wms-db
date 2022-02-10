-- rdt_607ExtVal04
execute rdt.rdtDropMsg 164601, 164650

execute rdt.rdtAddMsg 164601, 10, '164601 Over receive ',   'us_english', 607
execute rdt.rdtAddMsg 164602, 10, '164602Invalid carton',   'us_english', 607

select * from rdt.rdtmsg(nolock) where message_id between 164601 and 164650