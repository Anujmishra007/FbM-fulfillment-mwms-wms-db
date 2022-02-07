--rdt_840ExtValid10
rdt.rdtDropMsg 162651 , 162700

execute rdt.rdtAddMsg 162651, 10, '62651^Upd OdDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 162652, 10, '62652^Upd OdHdr Fail',   'us_english', 840
execute rdt.rdtAddMsg 162653, 10, 'ORDER CANCELLED',        'us_english', 840
execute rdt.rdtAddMsg 162654, 10, 'ORDER CANCELLED',        'us_english', 840
execute rdt.rdtAddMsg 162655, 10, '62655^INVALID LOT02',    'us_english', 840

-- WMS-16272
execute rdt.rdtAddMsg 162656, 10, 'PLS USE BOX',             'us_english', 840
execute rdt.rdtAddMsg 162657, 10, 'PLS USE GWP',             'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 162651 AND 162700