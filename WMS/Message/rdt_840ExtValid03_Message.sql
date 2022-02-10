-- rdt_840ExtValid03
execute rdt.rdtdropmsg 133851 , 133900

execute rdt.rdtAddMsg 133851, 10, '33851^ONLY CARTON #1',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 133851 and 133900
