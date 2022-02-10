--rdtfnc_MoveToUCC_V7
execute rdt.rdtdropmsg 148351 , 148400	

execute rdt.rdtAddMsg 148351, 10, '48351^TOLOC NEEDED',   'us_english', 639
execute rdt.rdtAddMsg 148352, 10, '48352^INV TOLOC',      'us_english', 639
execute rdt.rdtAddMsg 148353, 10, '48353^DIFF FACILITY',  'us_english', 639
execute rdt.rdtAddMsg 148354, 10, '48354^LOSEUCC TOLOC',  'us_english', 639
execute rdt.rdtAddMsg 148355, 10, '48355^FROMLOC NEEDED', 'us_english', 639
execute rdt.rdtAddMsg 148356, 10, '48356^INV FROMLOC',    'us_english', 639
execute rdt.rdtAddMsg 148357, 10, '48357^DIFF FACILITY',  'us_english', 639
execute rdt.rdtAddMsg 148358, 10, '48358^NOT LOSEUCC',    'us_english', 639
execute rdt.rdtAddMsg 148359, 10, '48359^Same FromToLOC', 'us_english', 639
execute rdt.rdtAddMsg 148360, 10, '48360^INV ID',         'us_english', 639
execute rdt.rdtAddMsg 148361, 10, '48361^SKU NEEDED',     'us_english', 639
execute rdt.rdtAddMsg 148362, 10, '48362^INV SKU',        'us_english', 639
execute rdt.rdtAddMsg 148364, 10, '48364^MultiSKUBarcod', 'us_english', 639
execute rdt.rdtAddMsg 148365, 10, '48365^Nothing ToMove', 'us_english', 639
execute rdt.rdtAddMsg 148366, 10, '48366^NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148367, 10, '48367^INV QTY',        'us_english', 639
execute rdt.rdtAddMsg 148368, 10, '48368^INV QTY',        'us_english', 639
execute rdt.rdtAddMsg 148369, 10, '48369^SKU NOT SAME',   'us_english', 639
execute rdt.rdtAddMsg 148370, 10, '48370^QTYAVL NOTENUF', 'us_english', 639
execute rdt.rdtAddMsg 148371, 10, '48371^NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148372, 10, '48372^NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148373, 10, '48373^TOUCC NEEDED',   'us_english', 639
execute rdt.rdtAddMsg 148374, 10, '48374^INVALID FORMAT', 'us_english', 639
execute rdt.rdtAddMsg 148375, 10, '48375^TOUCC EXISTS',   'us_english', 639

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148351 AND 148400