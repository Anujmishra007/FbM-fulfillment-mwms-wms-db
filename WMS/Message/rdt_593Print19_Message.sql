--rdt_593Print19
execute rdt.rdtdropmsg 119351 , 119400

execute rdt.rdtAddMsg '119351', 10, '19351^VALUE REQ',      'us_english'
execute rdt.rdtAddMsg '119352', 10, '19352^INV ORDERS',     'us_english'
execute rdt.rdtAddMsg '119353', 10, '19353^INV CUS ORDERS', 'us_english'
execute rdt.rdtAddMsg '119354', 10, '19354^ORD NOT ALLOC',  'us_english'
execute rdt.rdtAddMsg '119355', 10, '19355^PaperPrnterReq', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 119351 AND 119400