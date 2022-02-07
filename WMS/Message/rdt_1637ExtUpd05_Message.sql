--rdt_1637ExtUpd05
execute rdt.rdtDropMsg 144001 , 144050

execute rdt.rdtAddMsg 144001, 10, '44001^INS OTMIDT ERR',      'us_english', 1637
execute rdt.rdtAddMsg 144002, 10, '44002^INS OTMLOG ERR',      'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 144001 and 144050