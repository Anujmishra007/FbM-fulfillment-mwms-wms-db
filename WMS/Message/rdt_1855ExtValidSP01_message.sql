
select * from rdt.rdtmsg (nolock) where message_id between '173301' and '173350'

-- rdt_1855ExtValidSP01
execute rdt.rdtDropMsg 173301, 173350

execute rdt.rdtAddMsg 173301, 10, '173301 InvCartPrefix', 'us_english', 1855
