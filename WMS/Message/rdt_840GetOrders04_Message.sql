--rdt_840GetOrders04
exec rdt.rdtDropMsg 166351 , 166400

execute rdt.rdtAddMsg 166351, 10, '166351No Orders',        'us_english', 840
execute rdt.rdtAddMsg 166352, 10, '166352^ID > 1 Orders',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 166351 and 166400



