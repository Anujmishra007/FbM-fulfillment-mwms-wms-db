-- rdt_LottableFormat_904ValidateL2L4
execute rdt.rdtDropMsg 103751 , 103800

execute rdt.rdtAddMsg 103751, 10, '03751^Invalid LOT01',    'us_english'
execute rdt.rdtAddMsg 103752, 10, '03752^Invalid LOT02',    'us_english'
execute rdt.rdtAddMsg 103753, 10, '03753^Invalid LOT03',    'us_english'
execute rdt.rdtAddMsg 103754, 10, '03754^Invalid LOT04',    'us_english'
execute rdt.rdtAddMsg 103755, 10, '03755^Invalid LOT05',    'us_english'
execute rdt.rdtAddMsg 103756, 10, '03756^Invalid LOT06',    'us_english'
execute rdt.rdtAddMsg 103757, 10, '03757^Invalid LOT07',    'us_english'
execute rdt.rdtAddMsg 103758, 10, '03758^Invalid LOT08',    'us_english'
execute rdt.rdtAddMsg 103759, 10, '03759^Invalid LOT09',    'us_english'
execute rdt.rdtAddMsg 103760, 10, '03760^Invalid LOT10',    'us_english'
execute rdt.rdtAddMsg 103761, 10, '03761^Invalid LOT11',    'us_english'
execute rdt.rdtAddMsg 103762, 10, '03762^Invalid LOT12',    'us_english'
execute rdt.rdtAddMsg 103763, 10, '03763^Invalid LOT13',    'us_english'
execute rdt.rdtAddMsg 103764, 10, '03764^Invalid LOT14',    'us_english'
execute rdt.rdtAddMsg 103765, 10, '03765^Invalid LOT15',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 103751 and 103800