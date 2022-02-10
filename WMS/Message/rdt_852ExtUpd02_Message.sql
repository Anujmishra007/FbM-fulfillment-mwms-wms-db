--rdt_852ExtUpd02
exec rdt.rdtDropMsg 170251  , 170300	

execute rdt.rdtAddMsg 170251, 10, '170251InvalidRC', 'us_english', 852

select * from rdt.rdtmsg (nolock) where message_id between 170251 and 170300



