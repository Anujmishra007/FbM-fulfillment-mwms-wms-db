--rdt_593ShipLabel04
execute rdt.rdtDropMsg 102351 , 102400

execute rdt.rdtAddMsg '102351', 10, '02351^ASN # REQ',      'us_english'
execute rdt.rdtAddMsg '102352', 10, '02352^INVALID ASN #',  'us_english'
execute rdt.rdtAddMsg '102353', 10, '02353^SKU/UPC REQ',    'us_english'
execute rdt.rdtAddMsg '102354', 10, '02354^INVALID SKU',    'us_english'
execute rdt.rdtAddMsg '102355', 10, '02355^SameBarCodeSKU', 'us_english'
execute rdt.rdtAddMsg '102356', 10, '02356^INVALID QTY',    'us_english'
execute rdt.rdtAddMsg '102357', 10, '02357^SETUP BARTCFG',  'us_english'
execute rdt.rdtAddMsg '102358', 10, '02358^LABELPRNTERREQ', 'us_english'
execute rdt.rdtAddMsg '102359', 10, '02359^QTY OVER LIMIT', 'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 102351 AND 102400
