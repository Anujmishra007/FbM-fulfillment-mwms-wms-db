--rdt_848ExtUpd01
exec rdt.rdtDropMsg 111801 , 111850

execute rdt.rdtAddMsg 111801, 10, '11801^NO PICKKSLIP',     'us_english', 848
execute rdt.rdtAddMsg 111802, 10, '11802^DEL PACKD FAIL',   'us_english', 848

select * from rdt.rdtmsg (nolock) where message_id between 111801 and 111850