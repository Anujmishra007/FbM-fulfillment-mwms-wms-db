--rdtfnc_Print_Kimball_Label
--execute rdt.rdtdropmsg 77151 - 77200

execute rdt.rdtAddMsg '77151', 10, '77151^Option req',          'us_english'
execute rdt.rdtAddMsg '77152', 10, '77152^Invalid Option',      'us_english'
execute rdt.rdtAddMsg '77153', 10, '77153^SKU needed',          'us_english'
execute rdt.rdtAddMsg '77154', 10, '77154^Invalid SKU',         'us_english'
execute rdt.rdtAddMsg '77155', 10, '77155^MultiSKUBarcod',      'us_english'
execute rdt.rdtAddMsg '77156', 10, '77156^Invalid Qty',         'us_english'
execute rdt.rdtAddMsg '77157', 10, '77157^Qty Exceeded',        'us_english'
execute rdt.rdtAddMsg '77158', 10, '77158^No Printer',          'us_english'
execute rdt.rdtAddMsg '77159', 10, '77159^DWNOTSETUP',          'us_english'
execute rdt.rdtAddMsg '77160', 10, '77160^TGETDB NOT SET',      'us_english'
execute rdt.rdtAddMsg '77161', 10, '77161^INSERTPRTFAIL',       'us_english'

-- SOS289765
execute rdt.rdtAddMsg '77162', 10, '77162^Invalid Len',         'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 77151 AND 77200
