--rdt_840ExtInsPack05
execute rdt.rdtdropmsg 135451 , 135500

execute rdt.rdtAddMsg 135451, 10, '35451^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 135452, 10, '35452^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 135453, 10, '35453^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135454, 10, '35454^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135455, 10, '35455^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 135456, 10, '35456^GETTRACK# FAIL',  'us_english', 840
execute rdt.rdtAddMsg 135457, 10, '35457^GET LABEL FAIL',  'us_english', 840
execute rdt.rdtAddMsg 135458, 10, '35458^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135459, 10, '35459^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135460, 10, '35460^INSPACKINF ERR',  'us_english', 840

--WMS-20115
execute rdt.rdtAddMsg 135461, 10, '35461^InsTL2Log Err',  'us_english', 840
execute rdt.rdtAddMsg 135462, 10, '35462^UPD CTTRK Err',  'us_english', 840


select * from rdt.rdtmsg (nolock) where message_id between 135451 and 135500
