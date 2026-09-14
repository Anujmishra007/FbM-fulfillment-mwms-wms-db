-- rdt_994PackCfmSP01
-- 281201 - 281250
execute rdt.rdtDropMsg 281201, 281250

execute rdt.rdtAddMsg 281201, 10, '281201PackByFromDropID',    'us_english', 994, 0, '281201: Pack by FromDropID is enabled.'
execute rdt.rdtAddMsg 281202, 10, '281202InsPickDtlKeyFail',   'us_english', 994, 0, '281202: Failed to collect PickDetail keys.'
execute rdt.rdtAddMsg 281203, 10, '281203UpdPickDtlDropIDFail','us_english', 994, 0, '281203: Failed to update PickDetail DropID.'
execute rdt.rdtAddMsg 281204, 10, '281204UpdPickDtlStatusFail','us_english', 994, 0, '281204: Failed to update PickDetail status.'
execute rdt.rdtAddMsg 281205, 10, '281205PackCfmFail',         'us_english', 994, 0, '281205: Failed to confirm pack.'
