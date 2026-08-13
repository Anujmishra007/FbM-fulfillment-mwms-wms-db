--rdt.rdt_1764SwapID08
--277851 - 277900


execute rdt.rdtdropmsg 277851, 277900

execute rdt.rdtAddMsg 277851, 10, '277851^NeedID',                  'us_english', 1764, 0, '277851: ID is required'
execute rdt.rdtAddMsg 277852, 10, '277852^BadTaskKey',              'us_english', 1764, 0, '277852: Invalid TaskDetailKey'
execute rdt.rdtAddMsg 277853, 10, '277853^InvalidID',               'us_english', 1764, 0, '277853: Invalid ID'
execute rdt.rdtAddMsg 277854, 10, '277854^PalletCannotBePicked',    'us_english', 1764, 0, '277854: Pallet cannot be picked'
execute rdt.rdtAddMsg 277855, 10, '277855^UpdTaskFail',             'us_english', 1764, 0, '277855: Update task failed'
execute rdt.rdtAddMsg 277856, 10, '277856^UpdLLIFail',              'us_english', 1764, 0, '277856: Update inventory failed (new ID)'
execute rdt.rdtAddMsg 277857, 10, '277857^UpdLLIFail',              'us_english', 1764, 0, '277857: Update inventory failed (original ID)'
execute rdt.rdtAddMsg 277858, 10, '277858^PalletCannotBePicked',    'us_english', 1764, 0, '277858: Pallet cannot be picked'
execute rdt.rdtAddMsg 277859, 10, '277859^PalletCannotBePicked',    'us_english', 1764, 0, '277859: Pallet cannot be picked'
execute rdt.rdtAddMsg 277860, 10, '277860^PalletCannotBePicked',    'us_english', 1764, 0, '277860: Pallet cannot be picked'
execute rdt.rdtAddMsg 277861, 10, '277861^UpdTaskFail',             'us_english', 1764, 0, '277861: Update task failed'




select * from rdt.rdtmsg (nolock) where Message_ID between 277851 and 277900
