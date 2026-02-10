--rdt_600ExtVal_LCLDE
execute rdt.rdtdropmsg  218366, 218370
execute rdt.rdtAddMsg 218366, 10, '218366 REC: ',  'us_english', 600
execute rdt.rdtAddMsg 218367, 10, '218367 Customer SKU can not be LCLCASE',  'us_english', 600
execute rdt.rdtAddMsg 218368, 10, '218368 Customer SKU can not be LCLPAL',  'us_english', 600
execute rdt.rdtAddMsg 218369, 10, '218369 Customer SKU not exists in receipt',  'us_english', 600
execute rdt.rdtAddMsg 218370, 10, '218370 Mixed Customer on PLT',  'us_english', 600
select * from rdt.rdtmsg (nolock) where message_id in (218366, 218367, 218368, 218369,218370 )