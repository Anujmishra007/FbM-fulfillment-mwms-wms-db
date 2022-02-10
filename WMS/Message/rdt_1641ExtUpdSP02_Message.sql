-- rdt_1641ExtUpdSP02
execute rdt.rdtDropMsg 101201 , 101250	

execute rdt.rdtAddMsg 101201, 10, '01201^INS PLT FAIL',     'us_english'
execute rdt.rdtAddMsg 101202, 10, '01202^cCTN EXISTS',      'us_english'
execute rdt.rdtAddMsg 101203, 10, '01203^INS PLTDT FAIL',   'us_english'
execute rdt.rdtAddMsg 101204, 10, '01204^PKEY NOT FOUND',   'us_english'
execute rdt.rdtAddMsg 101205, 10, '01205^UPD PLT FAIL',     'us_english'
execute rdt.rdtAddMsg 101206, 10, '01206^UPD PLTDT FAIL',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 101201 AND 101250	