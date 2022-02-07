--rdt_826ExtVal01
exec rdt.rdtDropMsg 163151, 163200

execute rdt.rdtaddmsg 163151, 10, '63151^NoPickPosition',       'us_english'
execute rdt.rdtaddmsg 163152, 10, '63152^InvalidLocType',       'us_english'

select * from rdt.rdtmsg with (nolock) where message_id between 163151 and 163200