-- rdt_1580RcvFilter03 
execute rdt.rdtDropMsg 99051 , 99100

execute rdt.rdtAddMsg 99051, 10, '98801^Offset error',      'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 99051 and 99100