-- rdtIDXShipLabelReprn
-- EXEC RDT.RDTDROPMSG 88301 , 88350


execute rdt.rdtAddMsg '88301', 10, '88301^VALUE REQ',       'us_english'
execute rdt.rdtAddMsg '88302', 10, '88302^INV ORDERS',      'us_english'
execute rdt.rdtAddMsg '88303', 10, '88303^ORD NOT ALLOC',   'us_english'
execute rdt.rdtAddMsg '88304', 10, '88304^ORDERS SHIPPED',  'us_english'
execute rdt.rdtAddMsg '88305', 10, '88305^NO LOADKEY',      'us_english'
execute rdt.rdtAddMsg '88306', 10, '88306^NO SHIPPERKEY',   'us_english'
execute rdt.rdtAddMsg '88307', 10, '88307^LABELPRNTERREQ',  'us_english'
execute rdt.rdtAddMsg '88308', 10, '88308^REPRINT FAILED',  'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 88301 AND 88350
