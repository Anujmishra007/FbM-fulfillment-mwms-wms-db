--rdt_837ExtValid01
execute rdt.rdtDropMsg 151951 , 152000

execute rdt.rdtAddMsg 151951, 10, '51951^Orders Shipped',    'us_english', 837

select * from rdt.rdtmsg (nolock) where message_id between 151951 AND 152000