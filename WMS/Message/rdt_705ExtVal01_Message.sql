--rdt_705ExtVal01
exec rdt.rdtDropMsg 134301 , 134350

execute rdt.rdtaddmsg 134301, 10, '34301^Invalid ColName',  'us_english', 705
execute rdt.rdtaddmsg 134302, 10, '34302^Invalid RefNo',    'us_english', 705


select * from rdt.rdtmsg with (nolock) where message_id between 134301 and 134350