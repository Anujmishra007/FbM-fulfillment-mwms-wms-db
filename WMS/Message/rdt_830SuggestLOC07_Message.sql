--rdt_830SuggestLOC07
execute rdt.rdtdropmsg 277451, 277500

execute rdt.rdtAddMsg 277451, 10, '277451NoMoreTask    ', 'us_english', 830, 0, '277451: No more task'

select * from rdt.rdtmsg (nolock) where message_id between 277451 and 277500
