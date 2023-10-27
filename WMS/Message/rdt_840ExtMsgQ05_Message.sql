--rdt_840ExtMsgQ05
execute rdt.rdtDropMsg 204651 , 204700

execute rdt.rdtAddMsg 204651, 10, 'ELECTRONIC ITEM',        'us_english', 840
execute rdt.rdtAddMsg 204652, 10, 'FRAGILE        ',        'us_english', 840
execute rdt.rdtAddMsg 204653, 10, 'PACKAGING MATERIAL',     'us_english', 840
execute rdt.rdtAddMsg 204654, 10, 'VAS ITEM',               'us_english', 840
execute rdt.rdtAddMsg 204655, 10, 'THIS ORDERS INCLUDES',   'us_english', 840
execute rdt.rdtAddMsg 204656, 10, 'FRAGILE ITEM.',          'us_english', 840
execute rdt.rdtAddMsg 204657, 10, 'PLS USE BOX.',           'us_english', 840


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204651 AND 204700