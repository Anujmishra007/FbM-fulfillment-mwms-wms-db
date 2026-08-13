--rdt.rdt_1764ExtScn06
--278001 - 278050

execute rdt.rdtdropmsg 278001, 278050

execute rdt.rdtAddMsg 278001, 10, '278001^IDNotMatch',       'us_english', 1764, 0, '278001: ID does not match suggested ID'
execute rdt.rdtAddMsg 278002, 10, '278002^QTYAllocReplen',   'us_english', 1764, 0, '278002: Pallet has allocated or replenishment qty'

select * from rdt.rdtmsg (nolock) where Message_ID between 278001 and 278050
