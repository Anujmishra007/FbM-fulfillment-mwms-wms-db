-- rdt_732ExtUpd01
execute rdt.rdtDropMsg 102951 , 103000


execute rdt.rdtAddMsg 102951, 10, '02951^Reset LOC Fail',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 102951 and 103000