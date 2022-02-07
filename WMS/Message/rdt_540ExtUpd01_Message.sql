--rdt_540ExtUpd01

exec rdt.rdtDropMsg 109501, 109550

execute rdt.rdtAddMsg 109501, 10, '09501^Close Ctn Fail',   'us_english', 540
execute rdt.rdtAddMsg 109502, 10, '09502^Close Ctn Fail',   'us_english', 540

select * from rdt.rdtmsg (nolock) where message_id between 109501 and 109550

