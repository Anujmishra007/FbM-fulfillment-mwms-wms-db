--rdt_1766ExtUpd03
--233051 - 233100

exec rdt.rdtDropMsg 233051 , 233100

execute rdt.rdtAddMsg 233051, 10, '233051UpdTaskFail',   'us_english', 1766
execute rdt.rdtAddMsg 233052, 10, '233052UpdTaskFail',   'us_english', 1766
execute rdt.rdtAddMsg 233053, 10, '233053UpdTaskFail',   'us_english', 1766

select * from rdt.rdtmsg (nolock) where message_id between 233051 AND 233100