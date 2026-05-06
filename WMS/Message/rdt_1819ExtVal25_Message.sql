--rdt_1819ExtVal
--258601 - 258650

exec rdt.rdtDropMsg 258601, 258650

execute rdt.rdtAddMsg 258601, 10, '258601^InvalidLocType', 'us_english', 1819, 0, '258601 Invalid Location Type'

select * from rdt.rdtmsg (NOLOCK) where message_id between 258601 and 258650
