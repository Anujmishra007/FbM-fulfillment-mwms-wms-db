
execute rdt.rdtdropmsg 257500, 257520

execute rdt.rdtAddMsg 257501, 10, '257501:INVALID_PALLET_ID',  'us_english', 511, 0, '257501: INVALID PALLET ID'
execute rdt.rdtAddMsg 257502, 10, '257502:ORDER_NOT_FOUND',  'us_english', 511, 0, '257502: ORDER NOT FOUND'
execute rdt.rdtAddMsg 257503, 10, '257503:LOC_NOT_MATCH',  'us_english', 511, 0, '257503: LOC NOT MATCH'





SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257500 AND 257520