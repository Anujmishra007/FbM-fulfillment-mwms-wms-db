--rdt_848ExtUpd02
exec rdt.rdtDropMsg 177501 , 177550

execute rdt.rdtAddMsg 177501, 10, '177501 NO PICKKSLIP ',   'us_english', 848
execute rdt.rdtAddMsg 177502, 10, '177502DEL PACKD FAIL',   'us_english', 848

select * from rdt.rdtmsg (nolock) where message_id between 177501 and 177550