--rdt_1711DefToTote01
execute rdt.rdtdropmsg 101451 , 101500

execute rdt.rdtAddMsg 101451, 10, '01451^GET SACK# FAIL',   'us_english'
execute rdt.rdtAddMsg 101452, 10, '01452^NOT WITHIN',       'us_english'
execute rdt.rdtAddMsg 101453, 10, '01453^DEFAULT SACK#',    'us_english'
execute rdt.rdtAddMsg 101454, 10, '01454^RANGE',            'us_english'
execute rdt.rdtAddMsg 101455, 10, '01455^SEND ALERT ERR',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 101451 and 101500