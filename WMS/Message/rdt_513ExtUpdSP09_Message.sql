--rdt_513ExtUpdSP09

execute rdt.rdtDropMsg 268701, 268750

execute rdt.rdtAddMsg 268701 ,10, '268701^UpdateFailed',    'us_english', 513, 0, '268701: Update pallet type failed'

select * from rdt.rdtmsg (nolock) where message_id between 268701 and 268750
