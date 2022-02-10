--rdt_523ExtValidSP04
exec rdt.rdtDropMsg 111751 , 111800

execute rdt.rdtAddMsg 111751, 10, '11751^PICK LOCATION',    'us_english', 523

select * from rdt.rdtmsg (nolock) where message_id between 111751 and 111800