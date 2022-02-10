--rdt_593PalletLabel01
execute rdt.rdtdropmsg 114351 , 114400

execute rdt.rdtAddMsg '114351', 10, '14351^VALUE REQ',      'us_english'
execute rdt.rdtAddMsg '114352', 10, '14352^INV ASN',        'us_english'
execute rdt.rdtAddMsg '114353', 10, '14353^INV ID',         'us_english'
execute rdt.rdtAddMsg '114354', 10, '14354^NO RPT SETUP',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114351 AND 114400