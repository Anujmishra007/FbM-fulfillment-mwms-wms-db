--rdt_840ExtInsPack20
execute rdt.rdtdropmsg 199451 , 199500

execute rdt.rdtAddMsg 199451, 10, '199451 UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 199452, 10, '199452 INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 199453, 10, '199453 INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199454, 10, '199454 UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199455, 10, '199455 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 199456, 10, '199456 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 199457, 10, '199457 ASSIGNTRK#ERR',   'us_english', 840
execute rdt.rdtAddMsg 199458, 10, '199458 GET LABEL ERR',   'us_english', 840
execute rdt.rdtAddMsg 199459, 10, '199459 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199460, 10, '199460 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199461, 10, '199461 UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199462, 10, '199462 UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199463, 10, '199463 GET PDKEY ERR',   'us_english', 840
execute rdt.rdtAddMsg 199464, 10, '199464 INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 199465, 10, '199465 UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 199451 AND 199500
