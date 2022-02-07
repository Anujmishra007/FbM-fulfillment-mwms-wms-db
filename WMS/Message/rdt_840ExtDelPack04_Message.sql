-- rdt_840ExtDelPack02 
execute rdt.rdtDropMsg 131851 , 131900

execute rdt.rdtAddMsg 131851, 10, '31851^UPD CTNTRK ERR',   'us_english'
execute rdt.rdtAddMsg 131852, 10, '31852^CLR CASE FAIL',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 131851 and 131900
