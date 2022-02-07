--rdt_Print20
execute rdt.rdtDropMsg 120051 , 120100

execute rdt.rdtAddMsg 120051, 10, '20051^VALUE REQ',     'us_english'
execute rdt.rdtAddMsg 120052, 10, '20052^INV ORDERS',    'us_english'
execute rdt.rdtAddMsg 120053, 10, '20053^ORD NOT ALLOC', 'us_english'
execute rdt.rdtAddMsg 120054, 10, '20054^ORDERS SHIPPED','us_english'
execute rdt.rdtAddMsg 120055, 10, '20055^NO PKSLIP NO',  'us_english'
execute rdt.rdtAddMsg 120056, 10, '20056^LabelPrnterReq','us_english'

--WMS9534
execute rdt.rdtAddMsg 120057, 10, '20057^Need Track No', 'us_english'
execute rdt.rdtAddMsg 120058, 10, '20058^Setup CODEKLP', 'us_english'
execute rdt.rdtAddMsg 120059, 10, 'No Invoice',          'us_english'
execute rdt.rdtAddMsg 120060, 10, 'Proceed To Hospital', 'us_english'
execute rdt.rdtAddMsg 120061, 10, '20061^No Printer',    'us_english'

--WMS-17438
execute rdt.rdtAddMsg 120062, 10, '20062^UPDCTNStatusEr','us_english'
execute rdt.rdtAddMsg 120063, 10, '20063^Label Printed', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 120051 AND 120100
