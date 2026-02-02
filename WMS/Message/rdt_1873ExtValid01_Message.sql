--rdt_1873ExtValid01
--252951 - 253000

execute rdt.rdtdropmsg 252951 , 253000

execute rdt.rdtAddMsg 252951, 10, '252951OnlySingSKUPlt',       'us_english', 1873, 0, '252951: Only Single SKU pallets are allowed'
execute rdt.rdtAddMsg 252952, 10, '252952InvalidBusr3',         'us_english', 1873, 0, '252952: Invalid SKU.busr3'
execute rdt.rdtAddMsg 252953, 10, '252953InvalidPutawayZone',   'us_english', 1873, 0, '252953: Invalid PAZone'
execute rdt.rdtAddMsg 252954, 10, '252954ExceedWgtCapacity',    'us_english', 1873, 0, '252954: Exceed loc weight capacity'
execute rdt.rdtAddMsg 252955, 10, '252955IDNotFound',           'us_english', 1873, 0, '252955: ID info not found'
execute rdt.rdtAddMsg 252956, 10, '252956PalletTypeEmpty',      'us_english', 1873, 0, '252956: Pallet type is empty'
execute rdt.rdtAddMsg 252957, 10, '252957PltTypeNotMatch',      'us_english', 1873, 0, '252957: Pallet Type Not Match'
execute rdt.rdtAddMsg 252958, 10, '252958^OVER MAX PALLET',     'us_english', 1873, 0, '252958: Over max pallet'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 252951 AND 253000
