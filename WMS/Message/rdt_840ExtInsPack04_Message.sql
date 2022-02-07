-- rdt_840ExtInsPack04
execute rdt.rdtdropmsg 133601 , 133650

execute rdt.rdtAddMsg 133601, 10, '33601^CARTON NO ERR',   'us_english', 840
execute rdt.rdtAddMsg 133602, 10, '33602^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 133603, 10, '33603^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 133604, 10, '33604^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 133605, 10, '33605^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 133606, 10, '33606^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 133607, 10, '33607^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 133608, 10, '33608^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 133609, 10, '33609^INSPKINFO FAIL',  'us_english', 840
execute rdt.rdtAddMsg 133610, 10, '33610^PACK CFM FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 133601 and 133650
