-- rdtHMPrintIT69Label01
-- EXEC RDT.RDTDROPMSG 85851 - 85900

execute rdt.rdtAddMsg '85851', 10, '85851^ASN REQ',         'us_english'
execute rdt.rdtAddMsg '85852', 10, '85852^INVALID ASN',     'us_english'
execute rdt.rdtAddMsg '85853', 10, '85853^ASN LINE REQ',    'us_english'
execute rdt.rdtAddMsg '85854', 10, '85854^INV ASN LINE',    'us_english'
execute rdt.rdtAddMsg '85855', 10, '85855^QTY REQ',         'us_english'
execute rdt.rdtAddMsg '85856', 10, '85856^INVALID QTY',     'us_english'
execute rdt.rdtAddMsg '85857', 10, '85857^QTY > MAXQTY',    'us_english'
execute rdt.rdtAddMsg '85858', 10, '85858^SKU REQ',         'us_english'
execute rdt.rdtAddMsg '85859', 10, '85859^COO REQ',         'us_english'
execute rdt.rdtAddMsg '85860', 10, '85860^LOT NO REQ',      'us_english'
execute rdt.rdtAddMsg '85861', 10, '85861^QTY REQ',         'us_english'
execute rdt.rdtAddMsg '85862', 10, '85862^INVALID SKU',     'us_english'
execute rdt.rdtAddMsg '85863', 10, '85863^SameBarcodeSku',  'us_english'
execute rdt.rdtAddMsg '85864', 10, '85864^LabelPrnterReq',  'us_english'
execute rdt.rdtAddMsg '85865', 10, '85865^DWNOTSetup',      'us_english'
execute rdt.rdtAddMsg '85866', 10, '85866^TgetDB Not Set',  'us_english'
execute rdt.rdtAddMsg '85867', 10, '85867^PrintTPXSETUP',   'us_english'
execute rdt.rdtAddMsg '85868', 10, '85868^INVALID QTY',     'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 85851 AND 85900
