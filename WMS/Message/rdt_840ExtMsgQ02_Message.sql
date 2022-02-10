-- rdt_840ExtMsgQ02
execute rdt.rdtDropMsg 110101 , 110150

execute rdt.rdtAddMsg 110101, 10, 'THIS ORDERS INCLUDES',   'us_english', 840
execute rdt.rdtAddMsg 110102, 10, 'FRAGILE ITEM.',          'us_english', 840
execute rdt.rdtAddMsg 110103, 10, 'PLS USE BOX.',           'us_english', 840
execute rdt.rdtAddMsg 110104, 10, 'PACKAGING MATERIAL',     'us_english', 840
execute rdt.rdtAddMsg 110105, 10, 'VAS ITEM',               'us_english', 840

-- WMS-12662
execute rdt.rdtAddMsg 110106, 10, 'ELECTRONIC ITEM',        'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID between 110101 and 110150