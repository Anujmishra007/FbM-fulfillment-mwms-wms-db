--rdt_973DefToTote01
execute rdt.rdtdropmsg 102851 , 102900

execute rdt.rdtAddMsg 102851, 10, '02851^GET SACK# FAIL',   'us_english'
execute rdt.rdtAddMsg 102852, 10, '02852^NOT WITHIN',       'us_english'
execute rdt.rdtAddMsg 102853, 10, '02853^DEFAULT SACK#',    'us_english'
execute rdt.rdtAddMsg 102854, 10, '02854^RANGE',            'us_english'
execute rdt.rdtAddMsg 102855, 10, '02855^SEND ALERT ERR',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 102851 AND 102900
