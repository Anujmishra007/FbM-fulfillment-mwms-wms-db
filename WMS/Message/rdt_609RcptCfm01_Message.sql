-- rdt_609RcptCfm01
execute rdt.rdtDropMsg 104601 , 104650

execute rdt.rdtAddMsg 104601, 10, '04601^RECEIVE FAIL',     'us_english'
execute rdt.rdtAddMsg 104602, 10, '04602^RECEIVE FAIL',     'us_english'
execute rdt.rdtAddMsg 104603, 10, '04603^RECEIVE FAIL',     'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 104601 AND 104650