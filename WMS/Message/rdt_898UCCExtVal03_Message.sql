--rdt_898UCCExtVal03
execute rdt.rdtdropmsg 142701, 142750	

execute rdt.rdtAddMsg 142701, 10, '42701^IDMix UCCNot',    'us_english', 898
execute rdt.rdtAddMsg 142702, 10, '42702^UCCMix IDNot',    'us_english', 898
execute rdt.rdtAddMsg 142703, 10, '42703^ID Mix SKU',      'us_english', 898

-- WMS10928
execute rdt.rdtAddMsg 142704, 10, '42704^UCC Received',    'us_english', 898

select * from rdt.rdtmsg (nolock) where message_id between 142701 AND 142750	
