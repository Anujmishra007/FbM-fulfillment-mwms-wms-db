-- rdt_840ExtInsPack11
execute rdt.rdtdropmsg 156601 , 156650

execute rdt.rdtAddMsg 156601, 10, '56601^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 156602, 10, '56602^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 156603, 10, '56603^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156604, 10, '56604^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156605, 10, '56605^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 156606, 10, '56606^NOT PREPAID',     'us_english', 840
execute rdt.rdtAddMsg 156607, 10, '56607^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 156608, 10, '56608^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 156609, 10, '56609^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 156610, 10, '56610^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156611, 10, '56611^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156612, 10, '56612^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156613, 10, '56613^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156614, 10, '56614^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 156615, 10, '56615^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156616, 10, '56616^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 156617, 10, '56617^PACKCFM FAIL',    'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 156601 AND 156650
