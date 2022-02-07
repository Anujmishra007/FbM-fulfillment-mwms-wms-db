

-- rdt_1641ExtUpdSP08
execute rdt.rdtDropMsg 160251  , 160300	

execute rdt.rdtAddMsg 160251, 10, '60251^INS PLT FAIL',     'us_english'
execute rdt.rdtAddMsg 160252, 10, '60252^cCTN EXISTS',      'us_english'
execute rdt.rdtAddMsg 160253, 10, '60253^INS PLTDT FAIL',   'us_english'
execute rdt.rdtAddMsg 160254, 10, '60254^PKEY NOT FOUND',   'us_english'
execute rdt.rdtAddMsg 160255, 10, '60255^UPD PLT FAIL',     'us_english'
execute rdt.rdtAddMsg 160256, 10, '60256^UPD PLTDT FAIL',   'us_english'
execute rdt.rdtAddMsg 160257, 10, '60257^OrderNotINID',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 160251 AND 160300	