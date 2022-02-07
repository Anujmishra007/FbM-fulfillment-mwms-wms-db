-- rdt_LottableFormat_DecodeSSCC01 
execute rdt.rdtDropMsg 96301 , 96350

execute rdt.rdtAddMsg 96301, 10, '96301^INVALID PREFIX',     'us_english'
execute rdt.rdtAddMsg 96302, 10, '96302^INVALID LENGTH',     'us_english'
execute rdt.rdtAddMsg 96303, 10, '96303^INVALID BARCODE',    'us_english'
execute rdt.rdtAddMsg 96304, 10, '96304^INVALID BARCODE',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 96301 and 96350