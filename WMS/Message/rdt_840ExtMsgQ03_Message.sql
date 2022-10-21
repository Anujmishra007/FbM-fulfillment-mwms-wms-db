--rdt_840ExtMsgQ03
execute rdt.rdtDropMsg 183351 , 183400

execute rdt.rdtAddMsg 183351, 10, 'FRAGILE INSIDE      ' ,     'us_english', 840
execute rdt.rdtAddMsg 183352, 10, 'HAZMAT INSIDE       ' ,     'us_english', 840
execute rdt.rdtAddMsg 183353, 10, 'PACKAGING MATERIAL  ' ,     'us_english', 840
execute rdt.rdtAddMsg 183354, 10, 'VAS ITEM            ' ,     'us_english', 840

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 183351 AND 183400

