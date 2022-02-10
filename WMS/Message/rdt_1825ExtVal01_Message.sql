--rdt_1825ExtVal01
exec rdt.rdtDropMsg 133551 , 133600

execute rdt.rdtaddmsg 133551, 10, '33551^UCC NO IN ASN',       'us_english'

select * from rdt.rdtmsg with (nolock) where message_id between 133551 and 133600