--rdt_1804FetchTask01
exec rdt.rdtDropMsg 133801 , 133850

execute rdt.rdtaddmsg 133801, 10, '33801^NO REC TO MOVE',       'us_english', 1804
execute rdt.rdtaddmsg 133802, 10, '33802^NO REC TO MOVE',       'us_english', 1804

select * from rdt.rdtmsg with (nolock) where message_id between 133801 and 133850