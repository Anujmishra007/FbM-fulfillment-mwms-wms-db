--rdt_840ExtInsPack21
execute rdt.rdtdropmsg 203601 , 203650

execute rdt.rdtAddMsg 203601, 10, '203601 UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 203602, 10, '203602 INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 203603, 10, '203603 INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203604, 10, '203604 UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203605, 10, '203605 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 203606, 10, '203606 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 203607, 10, '203607 ASSIGNTR# ERR',   'us_english', 840
execute rdt.rdtAddMsg 203608, 10, '203608 GET LABEL ERR',   'us_english', 840
execute rdt.rdtAddMsg 203609, 10, '203609 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203610, 10, '203610 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203611, 10, '203611 UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203612, 10, '203612 UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203613, 10, '203613 GET PDKEY ERR',   'us_english', 840
execute rdt.rdtAddMsg 203614, 10, '203614 INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 203615, 10, '203615 UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 203601 AND 203650
