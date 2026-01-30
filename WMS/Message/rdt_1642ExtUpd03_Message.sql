
execute rdt.rdtdropmsg 257561, 257580

execute rdt.rdtAddMsg 257561, 10, '257561:PALLET ID REQ',  'us_english',  1642, 0,  '257561: PALLET ID REQ'
execute rdt.rdtAddMsg 257562, 10, '257562:Bad Pallet',  'us_english',     1642, 0,     '257562: Bad Pallet'
execute rdt.rdtAddMsg 257563, 10, '257563:OrderShipped',  'us_english',   1642, 0,   '257563: Order Shipped'
execute rdt.rdtAddMsg 257564, 10, '257564:UNHOLD ID FAIL',  'us_english', 1642, 0, '257564: UNHOLD ID FAIL'
execute rdt.rdtAddMsg 257565, 10, '257565:AUTO SHIP FAIL',  'us_english', 1642, 0, '257565: AUTO SHIP FAIL'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257561 AND 257580