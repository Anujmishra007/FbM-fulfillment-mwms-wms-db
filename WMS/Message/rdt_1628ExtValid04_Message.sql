--rdt_1628ExtValid04
execute rdt.rdtdropmsg 157451 , 157500

execute rdt.rdtAddMsg 157451, 10, '57451^>SKU MaxCount',   'us_english', 1628
execute rdt.rdtAddMsg 157452, 10, '57452^>SKU MaxCount',   'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 157451 AND 157500
