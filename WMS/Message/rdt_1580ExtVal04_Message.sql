-- rdt_1580ExtVal04 
execute rdt.rdtDropMsg 98801 , 98850

execute rdt.rdtAddMsg 98801, 10, '98801^ID IS REQ',      'us_english'
execute rdt.rdtAddMsg 98802, 10, '98802^INVALID ID',     'us_english'
execute rdt.rdtAddMsg 98803, 10, '98803^1 PALLET ONLY',  'us_english'
execute rdt.rdtAddMsg 98804, 10, '98804^ALLOW 1 SKU',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 98801 and 98850