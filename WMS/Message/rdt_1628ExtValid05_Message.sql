--rdt_1628ExtValid05
execute rdt.rdtdropmsg 164051 , 164100

execute rdt.rdtAddMsg 164051, 10, '64051^>SKU MaxCount',   'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 164051 AND 164100
