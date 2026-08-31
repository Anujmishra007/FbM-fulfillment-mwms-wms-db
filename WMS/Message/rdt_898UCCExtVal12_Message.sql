--rdt_898UCCExtVal12
--267251 - 267300

exec rdt.rdtDropMsg 267251 , 267300

execute rdt.rdtAddMsg 267251, 10, '267251^InvalidUCC',    'us_english', 898

select * from rdt.rdtmsg with (nolock) where message_id between 267251 and 267300