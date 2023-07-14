--rdt_1650ExtValid02
rdt.rdtDropMsg 202001 , 202050

execute rdt.rdtAddMsg 202001, 10, '202001^NO ORDER FOUND',      'us_english', 1650
execute rdt.rdtAddMsg 202002, 10, '202002^NO MBOL CREATE',      'us_english', 1650
execute rdt.rdtAddMsg 202003, 10, '202003^CANNOTSCAN2TRK',      'us_english', 1650
execute rdt.rdtAddMsg 202004, 10, '202004^PLT SCN 2 DOOR',      'us_english', 1650
execute rdt.rdtAddMsg 202005, 10, '202005^PARTIAL PICKED',      'us_english', 1650
execute rdt.rdtAddMsg 202006, 10, '202006^Invalid Door',        'us_english', 1650
execute rdt.rdtAddMsg 202007, 10, 'THERE ARE PALLETS',          'us_english', 1650
execute rdt.rdtAddMsg 202008, 10, 'NOT SCAN TO DOOR.',          'us_english', 1650
execute rdt.rdtAddMsg 202009, 10, 'CANNOT CLOSE.',              'us_english', 1650

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 202001 AND 202050