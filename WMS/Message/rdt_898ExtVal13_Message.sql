
--rdt_898ExtVal13
--FCR-10628
execute rdt.rdtdropmsg 259701, 259750

execute rdt.rdtAddMsg 259701, 10, '259701^Wrong Loc Group',       'us_english', 898, 0, '259701 Wrong Loc Group'
execute rdt.rdtAddMsg 259702, 10, '259702^Pallet Closed',         'us_english', 898, 0, '259702 Pallet Closed. Use different pallet'
execute rdt.rdtAddMsg 259704, 10, '259704^OnLOT not triggered',   'us_english', 898, 0, '259704 OnLOT not triggered'
execute rdt.rdtAddMsg 225305, 10, '225305^SKUStyleDoesNotMatch',   'us_english',898, 0, '225305 SKUStyleDoesNotMatch'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 259701 AND 259750
