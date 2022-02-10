-- rdt_638RefNoLKUP05
execute rdt.rdtDropMsg 170301 , 170350	

execute rdt.rdtAddMsg 170301, 10, '170301Max2RefField', 'us_english', 638
execute rdt.rdtAddMsg 170302, 10, '170302InvalidRefNo', 'us_english', 638
execute rdt.rdtAddMsg 170303, 10, '170303MultiOrders', 'us_english', 638
execute rdt.rdtAddMsg 170304, 10, '170304OrderNoFound', 'us_english', 638
execute rdt.rdtAddMsg 170305, 10, '170305GetKeyFail', 'us_english', 638
execute rdt.rdtAddMsg 170306, 10, '170306InsReceiptFail', 'us_english', 638
execute rdt.rdtAddMsg 170307, 10, '170307ASNNotFound', 'us_english', 638

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 170301 and 170350
