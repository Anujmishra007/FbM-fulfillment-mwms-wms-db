--rdt_1628ExtValid06
execute rdt.rdtdropmsg 164651, 164700

execute rdt.rdtAddMsg 164651, 10, '164651^>SKU MaxCount',   'us_english', 1628
execute rdt.rdtAddMsg 164652, 10, '164652^>SKU MaxCount',   'us_english', 1628
execute rdt.rdtAddMsg 164653, 10, '164653^>DropIDClosed',   'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 164651 AND 164700
