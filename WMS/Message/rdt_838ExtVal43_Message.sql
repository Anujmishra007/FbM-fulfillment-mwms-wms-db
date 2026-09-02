--rdt_838ExtVal43
--execute rdt.rdtdropmsg 279451, 279500
execute rdt.rdtDropMsg 279451, 279500

execute rdt.rdtAddMsg 279451, 10, '279451^InvalidPSNO', 'us_english', 838, 0, '279451: Invalid PSNO'

select * from rdt.rdtmsg (nolock) where message_id between 279451 and 279500
