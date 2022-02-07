--rdt_1580ExtVal15
execute rdt.rdtDropMsg 151051 , 151100

execute rdt.rdtAddMsg 151051, 10, '51051^CASEID IN USE',    'us_english', 1580

select * from rdt.rdtmsg (nolock) where message_id between 151051 AND 151100