--rdt_511ExtValid09
--233301 - 233350

execute rdt.rdtdropmsg 233301 , 233350

execute rdt.rdtAddMsg 233301, 10, '233301IDNotAssociated',  'us_english', 511, 0, '23301: ID not associated with any Kit'
execute rdt.rdtAddMsg 233302, 10, '233302NoProdLine',       'us_english', 511, 0, '23302: KIT for the ID no production line'
execute rdt.rdtAddMsg 233303, 10, '233303InvalidProdLine',  'us_english', 511, 0, '23303: Prod line not a valid location'
execute rdt.rdtAddMsg 233304, 10, '233304OVER MAX PALLET',  'us_english', 511, 0, '23304: Over max pallet'
execute rdt.rdtAddMsg 233305, 10, '233305TaskExists',       'us_english', 511, 0, '23305: FromID has open task'
execute rdt.rdtAddMsg 233306, 10, '233306IDInMultiKit',     'us_english', 511, 0, '23305: FromID exists in multiple KitKey'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 233301 AND 233350
